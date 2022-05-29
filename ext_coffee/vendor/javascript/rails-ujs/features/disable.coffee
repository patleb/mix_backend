Rails.handleDisabledElement = (e) ->
  element = this
  Rails.stopEverything(e) if element.disabled or element.hasAttribute('disabled')

# Unified function to enable an element (link, button and form)
Rails.enableElement = (e) ->
  if e instanceof Event
    return if isXhrRedirect(e)
    element = e.target
  else
    element = e

  if element.matches(Rails.linkDisableSelector)
    enableLinkElement(element)
  else if element.matches(Rails.buttonDisableSelector) or element.matches(Rails.formEnableSelector)
    enableFormElement(element)
  else if element.matches(Rails.formSubmitSelector)
    enableFormElements(element)

# Unified function to disable an element (link, button and form)
Rails.disableElement = (e) ->
  element = if e instanceof Event then e.target else e
  if element.matches(Rails.linkDisableSelector)
    disableLinkElement(element)
  else if element.matches(Rails.buttonDisableSelector) or element.matches(Rails.formDisableSelector)
    disableFormElement(element)
  else if element.matches(Rails.formSubmitSelector)
    disableFormElements(element)

#  Replace element's html with the 'data-disable-with' after storing original html
#  and prevent clicking on it
disableLinkElement = (element) ->
  return if Rails.getData(element, 'ujs:disabled') or element.hasAttribute('disabled')
  replacement = element.getAttribute('data-disable-with')
  if replacement?
    Rails.setData(element, 'ujs:enable-with', element.innerHTML) # store enabled state
    element.innerHTML = replacement
  element.addEventListener('click', Rails.stopEverything) # prevent further clicking
  Rails.setData(element, 'ujs:disabled', true)

# Restore element to its original state which was disabled by 'disableLinkElement' above
enableLinkElement = (element) ->
  return unless Rails.getData(element, 'ujs:disabled')
  originalText = Rails.getData(element, 'ujs:enable-with')
  if originalText?
    element.innerHTML = originalText # set to old enabled state
    Rails.setData(element, 'ujs:enable-with', null) # clean up cache
  element.removeEventListener('click', Rails.stopEverything) # enable element
  Rails.setData(element, 'ujs:disabled', null)

# Disables form elements:
#  - Caches element value in 'ujs:enable-with' data store
#  - Replaces element text with value of 'data-disable-with' attribute
#  - Sets disabled property to true
disableFormElements = (form) ->
  Rails.formElements(form, Rails.formDisableSelector).forEach(disableFormElement)

disableFormElement = (element) ->
  return if Rails.getData(element, 'ujs:disabled') or element.hasAttribute('disabled')
  replacement = element.getAttribute('data-disable-with')
  if replacement?
    if element.matches('button')
      Rails.setData(element, 'ujs:enable-with', element.innerHTML)
      element.innerHTML = replacement
    else
      Rails.setData(element, 'ujs:enable-with', element.value)
      element.value = replacement
  element.disabled = true
  Rails.setData(element, 'ujs:disabled', true)

# Re-enables disabled form elements:
#  - Replaces element text with cached value from 'ujs:enable-with' data store (created in `disableFormElements`)
#  - Sets disabled property to false
enableFormElements = (form) ->
  Rails.formElements(form, Rails.formEnableSelector).forEach(enableFormElement)

enableFormElement = (element) ->
  return unless Rails.getData(element, 'ujs:disabled')
  originalText = Rails.getData(element, 'ujs:enable-with')
  if originalText?
    if element.matches('button')
      element.innerHTML = originalText
    else
      element.value = originalText
    Rails.setData(element, 'ujs:enable-with', null) # clean up cache
  element.disabled = false
  Rails.setData(element, 'ujs:disabled', null)

isXhrRedirect = (event) ->
  xhr = event.detail?[0]
  xhr?.getResponseHeader("X-Xhr-Redirect")?
