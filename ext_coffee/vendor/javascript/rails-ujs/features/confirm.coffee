Rails.handle_confirm = (e) ->
  Rails.stop_everything(e) unless allow_action(this)

# Default confirm dialog, may be overridden with custom confirm dialog in Rails.confirm
Rails.confirm = (message, element) ->
  confirm(message)

# For 'data-confirm' attribute:
# - Fires `confirm` event
# - Shows the confirmation dialog
# - Fires the `confirm:complete` event
#
# Returns `true` if no function stops the chain and user chose yes `false` otherwise.
# Attaching a handler to the element's `confirm` event that returns a `falsy` value cancels the confirmation dialog.
# Attaching a handler to the element's `confirm:complete` event that returns a `falsy` value makes this function
# return false. The `confirm:complete` event is fired whether or not the user answered true or false to the dialog.
allow_action = (element) ->
  message = element.getAttribute('data-confirm')
  return true unless message

  answer = false
  if Rails.fire(element, 'confirm')
    try answer = Rails.confirm(message, element)
    callback = Rails.fire(element, 'confirm:complete', [answer])

  answer and callback
