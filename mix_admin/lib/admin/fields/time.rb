# frozen_string_literal: true

module Admin
  module Fields
    class Time < DateTime
      register_option :input_type do
        :time
      end

      register_option :i18n_scope do
        [:time, :formats, :pretty]
      end

      def parse_value(value)
        parent_value = super(value)
        return unless parent_value
        value_with_tz = parent_value.in_time_zone
        Time.parse_utc(value_with_tz.strftime('%Y-%m-%d %H:%M:%S'))
      end

      def format_input(value)
        super&.sub(/^[\d-]+T/, '')
      end
    end
  end
end
