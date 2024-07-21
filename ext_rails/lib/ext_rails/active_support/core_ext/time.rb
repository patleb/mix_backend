# frozen_string_literal: true

class Time
  include DateAndTime::Conversions

  def self.today
    current.beginning_of_day
  end

  def db_date
    to_date.to_fs(:db).tr('-', '_')
  end
end
