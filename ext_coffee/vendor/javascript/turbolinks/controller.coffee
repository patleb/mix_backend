class Turbolinks.Controller
  @cache_size = 10
  @progress_bar_delay = 500

  constructor: ->
    @html = document.documentElement
    @on_scroll = Turbolinks.throttle(@on_scroll)
    @restoration_data = {}
    @clear_cache()
    @progress_bar = new Turbolinks.ProgressBar

  start: ->
    unless Turbolinks.supported
      return addEventListener('DOMContentLoaded', @dispatch_load, false)
    unless @started
      addEventListener('submit', @on_submit, true)
      addEventListener('click', @on_click, true)
      addEventListener('DOMContentLoaded', @dom_loaded, false)
      addEventListener('scroll', @on_scroll, false)
      @on_scroll()
      @start_history()
      @started = true
      @enabled = true

  disable: ->
    @enabled = false

  stop: ->
    if @started
      removeEventListener('submit', @on_submit, true)
      removeEventListener('click', @on_click, true)
      removeEventListener('DOMContentLoaded', @dom_loaded, false)
      removeEventListener('scroll', @on_scroll, false)
      @stop_history()
      @started = false

  visit: (location, { action = 'advance', restoration_id, same_page, html } = {}) ->
    unless Turbolinks.supported and not @is_reloadable(location)
      return window.location = location
    location = Turbolinks.Location.wrap(location)
    unless @dispatch_before_visit(location, action).defaultPrevented
      if @location_is_visitable(location)
        same_page = same_page ? location.is_same_page() and location.anchor?
        restoration_data = @get_restoration_data(restoration_id)
        @start_visit(location, action, { restoration_id, restoration_data, same_page, html })
      else
        window.location = location

  clear_cache: ->
    @cache = new Turbolinks.SnapshotCache(@constructor.cache_size)

  reload: (reason) ->
    @dispatch_reload(reason)
    window.location.reload()

  # History

  start_history: ->
    @location = Turbolinks.Location.current_location()
    @restoration_id = Rails.uid()
    @initial_location = @location
    @initial_restoration_id = @restoration_id
    addEventListener('popstate', @on_popstate, false)
    addEventListener('load', @on_load, false)
    @update_history('replace')

  stop_history: ->
    removeEventListener('popstate', @on_popstate, false)
    removeEventListener('load', @on_load, false)
    delete @initial_location
    delete @initial_restoration_id

  push_history: (location, @restoration_id) ->
    @location = Turbolinks.Location.wrap(location)
    @update_history('push')

  replace_history: (location, @restoration_id) ->
    @location = Turbolinks.Location.wrap(location)
    @update_history('replace')

  update_history: (method) ->
    state = turbolinks: { @restoration_id }
    history["#{method}State"](state, '', @location.toString())

  # Snapshot cache

  get_cached_snapshot: (location) ->
    @cache.get(location)?.clone()

  should_cache_snapshot: ->
    @get_snapshot().is_cacheable()

  cache_snapshot: ->
    if @should_cache_snapshot()
      unless @dispatch_before_cache().defaultPrevented
        snapshot = @get_snapshot()
        location = @rendered_location or Turbolinks.Location.current_location()
        Turbolinks.defer =>
          @cache.put(location, snapshot.clone())
          @dispatch_cache()

  # Scrolling

  scroll_to_anchor: (name) ->
    if element = @get_anchor(name)
      element.scrollIntoView()
      element.focus()

  scroll_to_position: ({ x, y }) ->
    window.scrollTo(x, y)

  # View

  get_root_location: ->
    @get_snapshot().get_root_location()

  get_anchor: (name) ->
    @get_snapshot().get_anchor(name)

  get_snapshot: ->
    Turbolinks.Snapshot.from_element(@html)

  render: ({ snapshot, error, preview }, callback) ->
    @mark_as_preview(preview)
    if snapshot?
      Turbolinks.SnapshotRenderer.render(callback, @get_snapshot(), Turbolinks.Snapshot.wrap(snapshot), preview)
    else
      Turbolinks.ErrorRenderer.render(callback, error)

  render_view: (new_body, callback, preview) ->
    unless @dispatch_before_render(new_body, !!preview).defaultPrevented
      callback()
      @rendered_location = @current_visit.location
      @dispatch_render(new_body, !!preview)

  # Visit

  request_started: (visit) ->
    @progress_bar.set_value(0)
    if visit.should_issue_request()
      @progress_bar_timeout = setTimeout(@show_progress_bar, @constructor.progress_bar_delay)
    else
      @show_progress_bar()

  request_finished: (visit) ->
    @progress_bar.set_value(1)
    @hide_progress_bar()

  # Event handlers

  dom_loaded: =>
    @rendered_location = @location
    @dispatch_load(once: true)

  on_submit: =>
    removeEventListener('submit', @submit_bubbled, false)
    addEventListener('submit', @submit_bubbled, false)

  submit_bubbled: (event) =>
    return unless @enabled and event.target.matches('form[method=get]:not([data-remote=true])')
    { target, submitter } = event
    if @is_visitable(submitter) and (submitter.getAttribute('formmethod')?.toUpperCase() ? 'GET') is 'GET'
      url = submitter.getAttribute('formaction') ? target.getAttribute('action') ? target.action
      return if @is_reloadable(url)
      location = new Turbolinks.Location(url)
      params = Rails.serializeElement(target, submitter)
      location.push_query(params)
      action = submitter.getAttribute('data-turbolinks-action') ? target.getAttribute('data-turbolinks-action') ? 'advance'
      if @location_is_visitable(location)
        unless @dispatch_search(target, location).defaultPrevented
          Rails.stopEverything(event)
          @visit(location, { action, same_page: false })

  on_click: =>
    removeEventListener('click', @click_bubbled, false)
    addEventListener('click', @click_bubbled, false)

  click_bubbled: (event) =>
    return unless @enabled and @is_significant_click(event)
    target = event.composedPath?()[0] or event.target
    if @is_visitable(target) and (link = target.closest('a[href]:not([target^=_]):not([download])'))
      url = link.getAttribute('href')
      return if @is_reloadable(url)
      location = new Turbolinks.Location(url)
      action = link.getAttribute('data-turbolinks-action') ? 'advance'
      if @location_is_visitable(location)
        unless @dispatch_click(link, location).defaultPrevented
          event.preventDefault()
          @visit(location, { action })

  on_popstate: (event) =>
    return unless @enabled and @should_handle_popstate()
    if restoration_id = @get_restoration_id(event)
      anchored = @location.anchor? or Turbolinks.Location.current_location().anchor?
      same_page = @location.is_same_page() and anchored
      @location = Turbolinks.Location.current_location()
      @restoration_id = restoration_id
      restoration_data = @get_restoration_data(@restoration_id)
      @start_visit(@location, 'restore', { @restoration_id, restoration_data, same_page, history_changed: true })

  on_load: (event) =>
    Turbolinks.defer =>
      @page_loaded = true

  on_scroll: (event) =>
    @update_position(x: window.pageXOffset, y: window.pageYOffset)

  # Application events

  dispatch_search: (form, location) ->
    Turbolinks.dispatch('turbolinks:search', target: form, data: { url: location.absolute_url }, cancelable: true)

  dispatch_click: (link, location) ->
    Turbolinks.dispatch('turbolinks:click', target: link, data: { url: location.absolute_url }, cancelable: true)

  dispatch_before_visit: (location, action) ->
    Turbolinks.dispatch('turbolinks:before-visit', data: { url: location.absolute_url, action }, cancelable: true)

  dispatch_visit: (location, action) ->
    Turbolinks.dispatch('turbolinks:visit', data: { url: location.absolute_url, action })

  dispatch_before_cache: ->
    Turbolinks.dispatch('turbolinks:before-cache', cancelable: true)

  dispatch_cache: ->
    Turbolinks.dispatch('turbolinks:cache')

  dispatch_before_render: (new_body, preview) ->
    Turbolinks.dispatch('turbolinks:before-render', data: { new_body, preview }, cancelable: true)

  dispatch_render: (new_body, preview) ->
    Turbolinks.dispatch('turbolinks:render', data: { new_body, preview })

  dispatch_load: (info = {}) ->
    Turbolinks.dispatch('turbolinks:load', data: { url: @location?.absolute_url, info })

  dispatch_reload: (reason) ->
    Turbolinks.dispatch('turbolinks:reload', data: { reason })

  dispatch_hashchange: (location_was, location) ->
    if window.HashChangeEvent?
      dispatchEvent(new HashChangeEvent('hashchange', { oldURL: location_was.toString(), newURL: location.toString() }))

  # Private

  start_visit: (location, action, properties) ->
    @current_visit?.cancel()
    @current_visit = @create_visit(location, action, properties)
    @current_visit.start()
    @dispatch_visit(location, action)

  create_visit: (location, action, { restoration_id, restoration_data, same_page, html, history_changed } = {}) ->
    visit = new Turbolinks.Visit(location, action, html)
    visit.restoration_id = restoration_id ? Rails.uid()
    visit.restoration_data = Turbolinks.copy(restoration_data)
    visit.same_page = same_page
    visit.history_changed = history_changed
    visit.referrer = @location
    visit

  is_significant_click: (event) ->
    not (event.defaultPrevented or Rails.is_meta_click(event))

  is_visitable: (node) ->
    if container = node.closest('[data-turbolinks]')
      container.getAttribute('data-turbolinks') isnt 'false'
    else
      true

  is_reloadable: (url) ->
    not (url instanceof Turbolinks.Location) and url?.charAt(0) is '?'

  location_is_visitable: (location) ->
    location.is_prefixed_by(@get_root_location()) and location.is_html()

  get_restoration_data: (restoration_id) ->
    @restoration_data[restoration_id] ?= {}

  should_handle_popstate: ->
    # Safari dispatches a popstate event after window's load event, ignore it
    (@page_loaded or document.readyState is 'complete') and
      @restoration_id isnt event.state?.turbolinks?.restoration_id

  get_restoration_id: (event) ->
    if event.state
      (event.state.turbolinks ? {}).restoration_id
    else if Turbolinks.Location.current_location().is_equal_to(@initial_location)
      @initial_restoration_id

  mark_as_preview: (preview) ->
    if preview
      @html.setAttribute('data-turbolinks-preview', '')
    else
      @html.removeAttribute('data-turbolinks-preview')

  update_position: (@position) ->
    restoration_data = @get_restoration_data(@restoration_id)
    restoration_data.position = @position

  show_progress_bar: =>
    @progress_bar.show()

  hide_progress_bar: ->
    @progress_bar.hide()
    clearTimeout(@progress_bar_timeout)
