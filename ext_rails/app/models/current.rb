class Current < ActiveSupport::CurrentAttributes
  attribute :controller, :controller_was
  attribute :session_id, :request_id, :referer
  attribute :locale, :time_zone
  attribute :view
  attribute :virtual_types
end
