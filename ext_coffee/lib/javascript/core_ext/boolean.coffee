Boolean.override_methods
  blank: ->
    not this

  eql: (other) ->
    this is other

Boolean.define_methods
  to_b: ->
    @valueOf()

  to_i: ->
    if @valueOf() then 1 else 0

  to_f: ->
    if @valueOf() then 1.0 else 0.0

  to_d: ->
    if @valueOf() then 1.0 else 0.0

  to_s: ->
    @toString()

  safe_text: ->
    @toString()

  html_safe: ->
    true
