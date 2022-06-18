HTMLElement.define_methods
  is_a: (klass) ->
    @constructor is klass

  to_s: ->
    @outerHTML

  classes: ->
    Array.wrap(@classList)

  add_class: (tokens...) ->
    @classList.add(tokens...)
    this

  remove_class: (tokens...) ->
    @classList.remove(tokens...)
    this

  replace_class: (old_token, new_token) ->
    @classList.replace(old_token, new_token)

  toggle_class: (token, force = null) ->
    @classList.toggle(token, force)
