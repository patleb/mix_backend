class Js.FlashConcept
  global: true

  readers: ->
    header: -> Rails.find('#header')

  document_on: -> [
    'change', '#js_alert, #js_notice', (event, target) ->
      @clear_flash(target)
  ]

  leave: ->
    @clear_notice()

  timeout_for: (message) ->
    timeout = (message.length || 25) * 100
    timeout = 2500 if timeout < 2500
    timeout = 7500 if timeout > 7500
    timeout

  alert: (message) ->
    @header().append @flash_message('alert', message)...
    message

  notice: (message) ->
    @clear_notice()
    @header().append @flash_message('notice', message)...
    timeout = @timeout_for(message)
    @clear_notice_timeout = setTimeout(=>
      @clear_flash(@js_notice())
    , timeout)
    message

  # Private

  flash_message: (key, message) ->
    css_class = switch key
      when 'alert'  then 'alert-error'
      when 'notice' then 'alert-info'
      else throw "unsupported flash key: #{key}"
    [
      input$ id: "js_#{key}", type: 'checkbox'
      div$ '.alert.shadow-xl', class: css_class, -> [
        span_ message.simple_format().safe_text().html_safe(true)
        label_ '.btn.btn-circle.btn-xs', '&times;'.html_safe(true), for: "js_#{key}"
      ]
    ]

  js_notice: ->
    Rails.find('#js_notice')

  clear_notice: ->
    clearTimeout(@clear_notice_timeout)
    @clear_flash(@js_notice())

  clear_flash: (target) ->
    target?.nextSibling?.remove()
    target?.remove()
