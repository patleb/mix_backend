class Js.TagConcept
  ID_CLASSES = /^([#.][A-Za-z_-][:\w-]*)+$/

  HTML_TAGS: [
    'div'
    'input'
  ].to_set()

  ready_once: ->
    @define_tags()

  add_tags: (tags...) ->
    @HTML_TAGS = @HTML_TAGS.merge(tags.to_set())

  # Private

  define_tags: ->
    window.h_ = @h_
    window.h_if = @h_if
    window.h_unless = @h_unless
    @HTML_TAGS.each (tag) =>
      tag_ = "#{tag}_"
      tag$ = "#{tag}$"
      window[tag_] ?= (args...) => @with_tag(tag_, args...)
      window[tag$] ?= (args...) => @with_tag(tag$, args...)

  h_: (values...) =>
    if values.length is 1 and (text = values[0])?.is_a Function
      values = [text()]
    values = values.flatten().compact().map (item) ->
      item = '' unless item?
      item = item.safe_text() unless item.html_safe()
      item.to_s()
    values = values.join(' ')
    values.html_safe(true)

  h_if: (is_true, values...) =>
    return '' unless @continue(if: is_true)
    @h_(values...)

  h_unless: (is_true, values...) =>
    return '' unless @continue(unless: is_true)
    @h_(values...)

  with_tag: (tag, [css_or_content_or_options, content_or_options, options_or_content]...) ->
    if css_or_content_or_options?
      if css_or_content_or_options.is_a(String) and css_or_content_or_options.match ID_CLASSES
        id_classes = css_or_content_or_options
        if content_or_options?
          if content_or_options.is_a Object
            content = options_or_content
            options = content_or_options
          else
            content = content_or_options
            options = options_or_content
      else if css_or_content_or_options.is_a Object
        content = content_or_options
        options = css_or_content_or_options
      else
        content = css_or_content_or_options
        options = content_or_options if content_or_options?.is_a Object
    options = if options? then options.dup() else {}

    return '' unless @continue(options)

    if id_classes
      [id, classes] = @parse_id_classes(id_classes)
      options.id ||= id
      options.class = @merge_classes(options, classes)

    if options.class?.is_a Array
      options.class = options.class.select((item) -> item?.present()).join(' ')
      options.delete('class') if options.class.blank()

    if options.data?.is_a Object
      { data: options.delete('data') }.flatten_keys('-').each (key, value) ->
        options[key] = value

    element = true if tag.last() is '$'
    tag = tag.chop()

    escape = options.delete('escape') ? true
    content = options.delete('text') if options.text?
    content = content() if content?.is_a Function
    switch tag
      when 'a'
        options.rel = 'noopener' unless options.rel
    content = @h_(content) if content?.is_a Array

    result = @content_tag(tag, content ? '', options, escape)
    result = result.to_s().html_safe(true) unless element
    result

  parse_id_classes: (string) ->
    [classes, _separator, id_classes] = string.partition('#')
    classes = classes.split('.')
    if id_classes
      [id, other_classes...] = id_classes.split('.')
      classes = classes.concat(other_classes)
    [id, classes]

  merge_classes: (options, classes) ->
    if options.has_key 'class'
      old_array = @classes_to_array(options.class)
      new_array = @classes_to_array(classes)
      new_array.union(old_array)
    else
      @classes_to_array(classes)

  classes_to_array: (classes) ->
    if classes?.is_a Array
      classes
    else
      classes?.split(' ') or []

  content_tag: (tag, text, options, escape) ->
    tag = document.createElement(tag)
    options.class = options.delete('class') # necessary to keep #id.classes order
    for name, value of options
      tag.setAttribute(name, value) if value?
    if escape and not text.html_safe()
      tag.textContent = text.safe_text()
    else
      tag.innerHTML = text.to_s()
    tag

  continue: (options = {}) ->
    if options.has_key 'if'
      is_true = options.delete('if')
      is_true = is_true() if is_true?.is_a Function
      return false unless is_true
    if options.has_key 'unless'
      is_true = options.delete('unless')
      is_true = is_true() if is_true?.is_a Function
      return false if is_true
    true
