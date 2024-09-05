require './test/test_helper'
require_relative './watch_mock'

MixJob::Watch.class_eval do
  prepend MixJob::WatchMock
end

Job.class_eval do
  json_attribute :result
end

Minitest.after_run do
  FileUtils.rm_rf(MixJob::Watch::ACTIONS)
end

module MixJob
  module ActionTest
    def self.nothing
      $task_snapshot.call
    end

    def self.error
      raise StandardError
    end

    def self.args(*args)
      puts args.inspect
    end
  end

  class WatchTest < Rake::TestCase
    self.task_name = 'job:watch'
    self.file_fixture_path = Gem.root('mix_job').join('test/fixtures/files').to_s
    self.use_transactional_tests = false

    let(:run_timeout){ 1 }
    let(:options){ {
      listen_timeout: 0.0001,
      poll_interval: 0.001,
      server_interval: 0.0001,
      max_pool_size: 2,
      kill_timeout: run_timeout - 0.2,
      keep_jobs: 10,
    } }
    let(:actions){ good_actions + bad_actions.keys }
    let(:good_actions){ [
      'MixJob::ActionTest.nothing',
      'MixJob::ActionTest.args(null, yes, no, on, off, anystring)',
      'MixJob::ActionTest.args 1.0, "c", { a: 2, b: [ 0, nil ] }',
    ] }
    let(:bad_actions){ {
      'MixJob::ActionTest.error' => StandardError,
      'MixJob::ActionTest.error(2)' => ArgumentError,
      'MixJob::ActionTest.args({ "a" => 2})' => Psych::SyntaxError,
    } }

    before(:all) do
      FileUtils.mkdir_p MixJob::Watch::ACTIONS
    end

    before do
      mock_request(:success)
      mock_request(:server_error).to_return(status: [500, 'Internal Server Error'])
      mock_request(:client_error).to_timeout
    end

    test '#restore_signals' do
      actions.each do |action|
        Pathname.new("#{MixJob::Watch::ACTIONS}/#{Time.current.to_nanoseconds}.rb").write(action)
      end
      run_task(goto: 'restore_signals')
    end

    test '#setup_trapping' do
      run_task(goto: 'setup_trapping')
    end

    test '#setup_signaling' do
      run_task(goto: 'setup_signaling', **options)
    end

    test '#setup_listening' do
      run_task(goto: 'setup_listening', **options)
    end

    test '#setup_polling' do
      status = mock; status.stubs(:success?).returns(true)
      Process::Passenger.any_instance.expects(:passenger_status).at_least_once.returns(
        [file_fixture('passenger_status.xml').read, status]
      )
      run_task(goto: 'setup_polling', skip: 'setup_listening', **options.merge(max_pool_size: 1))
    end

    test '#wait_for_termination' do
      run_task(goto: 'wait_for_termination', **options.merge(max_pool_size: 1))
    end

    context 'with server error' do
      test '#setup_listening' do
        status = mock; status.stubs(:success?).returns(false)
        status_next = mock; status_next.stubs(:success?).at_least_once.returns(true)
        Process::Passenger.any_instance.expects(:passenger_status).at_least_once.returns(
          ["ERROR: Phusion Passenger doesn't seem to be running.", status],
          [file_fixture('passenger_status.xml').read, status_next]
        )
        run_task(test: 'not_dequeue_on_error', skip: 'setup_polling,wait_for_termination', **options)
      end
    end

    def mock_request(result)
      stub_request(:post, Regexp.new(Job.url(job_class: '[\w:]+', job_id: '[\w-]+'))).with(
        body: hash_including(job: hash_including(result: result.to_s)),
        headers: { connection: 'Keep-Alive' }
      )
    end

    def job_url(result = nil)
      Job.new(job_data(result)).url(result: result || :success)
    end

    def job_data(result = nil)
      { job_class: 'SimpleJob', job_id: SecureRandom.uuid, result: result || :success}
    end
  end
end
