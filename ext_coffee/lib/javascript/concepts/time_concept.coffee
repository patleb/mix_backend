class Js.TimeConcept
  global: true

  constants: ->
    ZONES: 'form input[name=_timezone]'
    FORMATS: 'time[datetime][data-format]'
    FORMATTED: 'js_time:formatted'

  document_on: -> [
    'turbolinks:request-start', document, ({ data: { xhr }}) ->
      xhr.setRequestHeader('X-Timezone', @zone)

    'turbolinks:before-render', document, ({ defaultPrevented, data: { new_body, preview }}) ->
      return if defaultPrevented or preview
      @refresh(new_body)

    Js.Component.CHANGE, document, ({ detail: { elements }}) ->
      elements.each (uid, element) =>
        @refresh(element)
  ]

  ready_once: ->
    @zone = try Intl.DateTimeFormat().resolvedOptions().timeZone
    @zone = -(new Date().getTimezoneOffset()) * 60 if not @zone or @zone.start_with('+', '-')
    prepend_to Rails, 'ajax', (options) =>
      options.headers ?= {}
      options.headers['X-Timezone'] = @zone
    @refresh()

  refresh: (root = Rails) ->
    @refresh_zones(root)
    @refresh_formats(root)

  # Private

  refresh_zones: (root) ->
    root.once @ZONES, (input) =>
      input.value = @zone

  refresh_formats: (root) ->
    elements = []
    root.once @FORMATS, (element) ->
      if content = format_datetime(element)
        element.setAttribute('aria-label', content) unless element.hasAttribute('aria-label')
        element.textContent = content
        elements.push element
    Rails.fire(document, @FORMATTED, { elements }) unless elements.empty()

  format_datetime = (element) ->
    datetime = element.getAttribute('datetime')?.to_date()
    return unless datetime?.present()
    format = element.getAttribute('data-format')
    datetime.strftime(format)
