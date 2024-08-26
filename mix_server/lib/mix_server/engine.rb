require 'ext_rails'
require 'mix_server/configuration'
require 'mix_server/routes'

autoload :Notice,    'mix_server/notice'
autoload :Throttler, 'mix_server/throttler'

module MixServer
  def self.routes
    @routes ||= {
      rescue: '/_rescues/javascript',
    }
  end

  def self.current_version
    @current_version ||= begin
      version = Rails.root.join('REVISION')
      version = version.exist? ? version.read : `git rev-parse --short HEAD`
      version.strip.first(7)
    end
  end

  def self.no_reboot_file
    shared_dir.join('tmp/files/no_reboot')
  end

  def self.deploy_dir
    @deploy_dir ||= "#{Rails.app}_#{Rails.env}"
  end

  def self.shared_dir
    if Rails.env.local?
      Rails.root
    else
      Rails.root.join('..', '..', 'shared').expand_path
    end
  end

  def self.idle?(timeout: nil)
    return _idle? unless timeout
    started_at = Time.current
    until (idle = _idle?)
      break if (Time.current - started_at) > timeout
      sleep ExtRuby.config.memoized_at_timeout
    end
    idle
  end

  def self._idle?
    # make sure that Passenger extra workers are killed and no extra rake tasks are running
    min_workers = MixServer.config.minimum_workers + 1 # include the current rake task or rails console
    Process.passenger.requests.blank? && Process::Worker.all.select{ |w| w.name == 'ruby' }.size <= min_workers
  end
  private_class_method :_idle?

  class Engine < ::Rails::Engine
    require 'mix_global'
    require 'mix_server/rack/utils'
    require 'mix_server/rake/dsl'
    require 'mix_server/sh'

    config.before_initialize do
      autoload_models_if_admin(['LogLines::Email', 'LogLines::Rescue'])

      if defined? PhusionPassenger
        PhusionPassenger.on_event(:starting_worker_process) do |_forked|
          Log.worker
        end

        PhusionPassenger.on_event(:stopping_worker_process) do
          Log.worker(stop: true)
        end
      end
    end

    initializer 'mix_server.append_migrations' do |app|
      append_migrations(app)
    end

    initializer 'mix_server.db_partitions' do
      ExtRails.config.db_partitions[:lib_log_lines] = :week
    end

    initializer 'mix_server.prepend_routes', before: 'ext_rails.append_routes' do |app|
      app.routes.prepend do
        MixUser::Routes.draw(self)
      end
    end

    ActiveSupport.on_load(:action_controller, run_once: true) do
      require 'mix_server/action_dispatch/middleware/exception_interceptor'
    end

    ActiveSupport.on_load(:action_controller_api) do
      require 'mix_server/action_controller/api'
    end

    ActiveSupport.on_load(:action_controller_base) do
      require 'mix_server/action_controller/base'
    end

    ActiveSupport.on_load(:action_mailer) do
      require 'mix_server/action_mailer/base/with_email_record'
    end
  end
end
