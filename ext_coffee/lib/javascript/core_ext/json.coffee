JSON.define_singleton_methods
  safe_parse: (str) ->
    try
      result = JSON.parse(str)
      if result && typeof(result) == 'object'
        result
      else
        false
    catch e
      false

  valid: (str) ->
    try
      JSON.parse(str)
      true
    catch e
      false
