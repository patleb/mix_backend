Object.define_singleton_methods
  dup: (object) ->
    result = {}
    for key, value of object
      result[key] = value
    result

  merge: (target, objects...) ->
    for object in objects
      for key, value of object
        target[key] = value
    target

  deep_merge: (target, others...) ->
    for object in others
      for key, value of object
        if target[key]?.is_a?(Object) and value?.is_a?(Object)
          target[key] = Object.deep_merge({}, target[key], value)
        else
          target[key] = value
    target

Object.define_methods
  __send__: (method, args...) ->
    if this[method]?.is_a Function
      this[method](args...)
    else
      @method_missing(method, args...)

  instance_exec: (block, args...) ->
    block.apply(this, args)

  instance_eval: (block) ->
    block.apply(this)

  dup: ->
    @constructor.dup(this)

  is_a: (klass) ->
    @constructor is klass

  to_a: ->
    [key, item] for key, item of this

  to_h: ->
    this

  blank: ->
    @size() is 0

  present: ->
    not @blank()

  presence: ->
    @valueOf() unless @blank()

  empty: ->
    @size() is 0

  size: ->
    @keys().length

  eql: (other) ->
    return false unless other?.is_a Object
    return false unless @size() is other.size()
    for key, item of this
      if item?
        return false unless item.eql(other[key])
      else
        return false if other[key]?
    true

  tap: (f_self) ->
    f_self(this)
    this

  has_key: (key) ->
    key of this

  delete: (key) ->
    item = this[key]
    delete this[key]
    item

  dig: (keys) ->
    digged = this
    keys.split('.').each_while (key) ->
      if digged.has_key?(key) or digged.has_index?(key)
        digged = digged[key]
        true
      else
        digged = undefined
        false
    digged

  any: (f_key_item_self) ->
    if f_key_item_self?
      for key, item of this
        return true if f_key_item_self(key, item, this)
      false
    else
      @size() > 0

  all: (f_key_item_self) ->
    for key, item of this
      return false unless f_key_item_self(key, item, this)
    true

  each: (f_key_item_self) ->
    for key, item of this
      f_key_item_self(key, item, this)
    return

  each_while: (f_key_item_self) ->
    for key, item of this
      return unless f_key_item_self(key, item, this)
    return

  each_with_object: (accumulator, f_key_item_memo_self) ->
    self = this
    @keys().reduce (memo, key) ->
      f_key_item_memo_self(key, self[key], memo, self)
      accumulator
    , accumulator

  map: (f_key_item_self) ->
    f_key_item_self(key, item, this) for key, item of this

  flatten_keys: (separator = '.', _prefix = null) ->
    @each_with_object {}, (key, item, memo) ->
      key = [_prefix, key].join(separator) if _prefix?
      if item?.is_a Object
        item.flatten_keys(separator, key).each (nested_key, nested_item) ->
          memo[nested_key] = nested_item
      else
        memo[key] = item

  find: (f_key_item_self) ->
    for key, item of this
      return item if f_key_item_self(key, item, this)
    return

  first: ->
    for key, item of this
      return [key, item]

  keys: ->
    Object.keys(this)

  values: ->
    item for key, item of this

  values_at: (keys...) ->
    this[key] for key in keys

  select: (f_key_item) ->
    result = {}
    for key, item of this when f_key_item(key, item)
      result[key] = item
    result

  select_map: (f_key_item) ->
    result = []
    for key, item of this when (value = f_key_item(key, item))
      result.push(value)
    result

  reject: (f_key_item) ->
    result = {}
    for key, item of this when not f_key_item(key, item)
      result[key] = item
    result

  slice: (keys...) ->
    result = {}
    for key in keys
      result[key] = this[key] if key of this
    result

  except: (keys...) ->
    result = {}
    for key, item of this
      result[key] = item if key not in keys
    result

  compact: ->
    @select (key, item) -> item?

  compact_blank: ->
    @select (key, item) -> item?.present()

  merge: (objects...) ->
    @constructor.merge(this, objects...)

  deep_merge: (others...) ->
    @constructor.deep_merge(this, others...)

  super_2: (name, args...) ->
    @constructor.__super__.__proto__[name].apply(this, args)

  super_3: (name, args...) ->
    @constructor.__super__.__proto__.__proto__[name].apply(this, args)

  html_map: (f_map) ->
    h_(@map(f_map))
