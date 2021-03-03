class Task < LibRecord
  include ActionView::Helpers::DateHelper

  has_userstamp

  enum name: MixTask.config.available_names
  enum state: {
    ready: 0,
    running: 1,
    success: 2,
    failure: 3,
    cancelled: 4,
    unknown: 5,
  }

  attribute :_perform, :boolean
  attribute :_from_later, :boolean

  validate :perform_later

  def self.delete_or_create_all
    where.not(name: MixTask.config.available_names.keys).delete_all
    MixTask.config.available_names.each_key do |name|
      task = find_or_initialize_by(name: name)
      task.save(validate: false)
    end
  end

  def self.path(name)
    path = (@path ||= RailsAdmin.routes[:edit].sub('__MODEL_NAME__', self.name.to_admin_param))
    path.sub('__ID__', name)
  end

  def path
    self.class.path(name)
  end

  def duration_avg
    distance_of_time(durations.average.seconds) unless durations.empty?
  end

  def duration
    distance_of_time(durations.last.seconds)
  end

  def parameters
    rake_task.arg_names
  end

  def description
    rake_task.comment
  end

  def arguments_visible?
    arguments.any?(&:present?)
  end

  def notify_editable?
    updater.nil? || updater.id == Current.user.id
  end

  def perform(arguments)
    update! arguments: arguments, _perform: true, _from_later: true
  rescue ActiveRecord::RecordInvalid
    save(validate: false)
    raise
  end

  private

  def perform_later
    return unless _perform?
    return perform_now if _from_later?

    clear_attribute_changes [:_perform]
    if notify_changed? && notify_editable?
      save(validate: false)
    end
    with_lock do
      if running?
        errors.add :base, :already_running
        throw :abort
      else
        Current.flash_later = true
        TaskJob.perform_later(name, *arguments)
        self.output = "[#{Time.current.utc}]#{MixTask::RUNNING} #{name}"
        self.state = :running
      end
    end
  end

  def perform_now
    started_at = Time.current.utc
    self.output = Parallel.map([[name, arguments]], in_processes: 1) do |(name, arguments)|
      String.try(:disable_colorization=, true)
      ARGV.clear
      ENV['RAKE_OUTPUT'] = true
      task = Rake::Task[name]
      task.invoke!(*arguments)
    rescue Exception
      task.output
    end.first
    result = output.lines.reject(&:blank?).last
    case
    when result.include?(MixTask::FAILURE) then set_error_state :failure
    when output.include?(MixTask::CANCEL)  then set_error_state :cancelled
    when result.include?(MixTask::SUCCESS)
      durations.shift until durations.size < MixTask.config.durations_max_size
      self.durations << (Time.current.utc - started_at).seconds.ceil(3)
      self.state = :success
    else
      set_error_state :unknown
    end
  end

  def set_error_state(type)
    errors.add :base, type
    self.state = type
  end

  def rake_task
    @rake_task ||= Rake::Task[name]
  end
end
