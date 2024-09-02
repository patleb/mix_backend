module LogLines
  POSTGRESQL_EXPECTATIONS = [
    {created_at: Time.new(2021,4,20,1,40,12.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,12.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,12.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,12.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,12.0,0), json_data: {event: "shutdown", stopped_at: Time.new(2021,4,20,1,40,12,0)}, message: {text: "shutdown: database system was shut down", level: :error}, pid: 48},
    {created_at: Time.new(2021,4,20,1,40,12.0,0), json_data: {event: "ready"}, message: {text: "ready: database system is ready", level: :info}, pid: 47},
    {created_at: Time.new(2021,4,20,1,40,15.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,15.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,15.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,15.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,16.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,40,16.0,0), json_data: {event: "shutdown", stopped_at: Time.new(2021,4,20,1,40,15,0)}, message: {text: "shutdown: database system was shut down", level: :error}, pid: 95},
    {created_at: Time.new(2021,4,20,1,40,16.0,0), json_data: {event: "ready"}, message: {text: "ready: database system is ready", level: :info}, pid: 1},
    {created_at: Time.new(2021,4,20,1,40,44.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,41,33.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,41,33.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,41,33.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,41,33.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,41,33.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,41,34.0,0), filtered: true},
    {filtered: true},
    {created_at: Time.new(2021,4,20,1,41,35.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,46,33.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,1,49,3.0,0),  filtered: true},
    {created_at: Time.new(2021,4,20,2,51,14.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,2,51,14.0,0), filtered: true},
    {created_at: Time.new(2021,4,20,2,51,14.0,0), json_data: {event: "shutdown", stopped_at: Time.new(2021,4,20,2,51,10,0)}, message: {text: "shutdown: database system was shut down", level: :error}, pid: 9806},
    {created_at: Time.new(2021,4,20,2,51,15.0,0), json_data: {event: "ready"}, message: {text: "ready: database system is ready", level: :info}, pid: 9804},
    {created_at: Time.new(2021,4,20,2,51,15.0,0), filtered: true},
  ]
end
