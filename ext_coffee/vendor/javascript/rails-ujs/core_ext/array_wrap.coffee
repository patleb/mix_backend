Array.wrap = (object) ->
  if object?
    if Array.as_array(object)
      Array::slice.call(object)
    else
      [object]
  else
    []
