class Current < ActiveSupport::CurrentAttributes
  attribute :controller, :controller_was
  attribute :session_id, :request_id, :referer
  attribute :locale, :timezone
  attribute :view
  attribute :virtual_records

  alias_method :locale_without_default, :locale
  def locale
    locale_without_default || I18n.default_locale
  end

  alias_method :timezone_without_default, :timezone
  def timezone
    timezone_without_default || Rails.application.config.time_zone
  end
end
