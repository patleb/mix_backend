module Sunzistrano
  TASK = '[TASK]'.freeze
  DONE = '[DONE]'.freeze
  FAIL = '[FAIL]'.freeze

  Cli.class_eval do
    desc 'rake [STAGE] [TASK] [--host] [--sudo] [--nohup] [--wait] [--verbose] [--kill] [--force]', 'Execute a rake task'
    method_options host: :string, sudo: false, nohup: false, wait: :string, verbose: false, kill: false, force: false
    def rake(stage, task)
      do_rake(stage, task)
    end

    no_tasks do
      def do_rake(stage, task)
        with_context(stage, :deploy) do
          run_job_cmd :rake, task
        end
      end

      alias_method :run_role_cmd_without_local_tasks, :run_role_cmd
      def run_role_cmd
        (sun.local_tasks || []).reject(&:blank?).each do |task|
          started_at = Concurrent.monotonic_time
          context = "RAILS_ENV=#{sun.env} RAILS_APP=#{sun.app} BASH_DIR=#{bash_dir}"
          command = "#{context} bin/rake #{task}"
          puts "[#{Time.now.utc}]#{TASK} #{task}".cyan
          output, status = capture2e(command)
          total = (Concurrent.monotonic_time - started_at).seconds.ceil(3)
          if status == 0
            puts output
            puts "[#{Time.now.utc}]#{DONE} #{task} -- : #{total} seconds".green
          else
            puts "[#{Time.now.utc}]#{FAIL} #{task} -- : #{total} seconds".red
            raise output
          end
        end
        run_role_cmd_without_local_tasks
      end

      def rake_remote_cmd(task)
        rake_output = sun.verbose || sun.nohup || sun.wait.present?
        environment = ["RAKE_OUTPUT=#{rake_output}", "RAILS_ENV=#{sun.env}", "RAILS_APP=#{sun.app}"]
        if sun.sudo
          rbenv_sudo = "rbenv sudo #{environment.join(' ')}"
        else
          context = environment.map{ |value| "export #{value};" }.join(' ')
        end
        path = "cd #{sun.deploy_path :current};"
        command = "bin/rake #{task}"
        if sun.wait.present?
          minutes, seconds = parse_wait
          raise "invalid wait '#{sun.wait}'" unless minutes
          sleep = "sleep #{seconds};" if seconds > 0
          name = rake_log_basename(command)
          <<-SH.squish
            echo -e '#{sleep} #{Sh.rbenv_ruby} #{path} #{rbenv_sudo} #{context} #{command} >> log/#{name}.log 2>&1' |
            at now + #{minutes} minutes
          SH
        elsif sun.nohup
          name = rake_log_basename(command)
          command = "#{command} >> log/#{name}.log 2>&1 & sleep 1 && echo $! > tmp/pids/#{name}.pid"
          <<-SH.squish
            #{Sh.rbenv_ruby} #{path} #{context} nohup #{rbenv_sudo} #{command}
          SH
        elsif sun.kill
          name = rake_log_basename(command)
          pid = "#{sun.deploy_path :current}/tmp/pids/#{name}.pid"
          <<-SH.squish
            ppid=$(cat #{pid});
            sudo pkill #{'-9' if sun.force} --parent $ppid &&
            rm -f #{pid} && echo "killed [$ppid] child processes" ||
            rm -f #{pid} && echo "could not kill [$ppid] child processes"
          SH
        else
          <<-SH.squish
            #{Sh.rbenv_ruby} #{path} #{rbenv_sudo} #{context} #{command} |&
            tee -a #{sun.deploy_path :current, BASH_LOG}
          SH
        end
      end

      def rake_log_basename(command)
        command.squish.gsub(/[^_\w]/, '-').gsub(/-{2,}/, '-').delete_prefix('-').delete_suffix('-')
      end

      def parse_wait
        duration = case sun.wait
          when /^(\d+)\.(second|minute|hour|day|week)s?$/
            ($1.to_i.send($2).from_now - Time.now).to_i
          else
            (Time.parse(sun.wait) - Time.now).to_i rescue nil
          end
        duration = 60 if duration && duration < 60
        [duration / 60, duration % 60] if duration
      end
    end
  end
end
