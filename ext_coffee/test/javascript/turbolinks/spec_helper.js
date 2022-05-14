import '@@vendor/rails-ujs/all'
import '@@vendor/turbolinks/all'

const events = [
  "turbolinks:before-cache",
  "turbolinks:before-render",
  "turbolinks:before-visit",
  "turbolinks:click",
  "turbolinks:load",
  "turbolinks:render",
  "turbolinks:request-start",
  "turbolinks:request-end",
  "turbolinks:visit",
].concat([
  "turbolinks:click-cancel",
  "turbolinks:click-only",
  "turbolinks:visit-reload",
])

const branches = {
  click_cancel: false,
  click_only: false,
  visit_reload: false,
}

beforeAll(() => {
  fixture.set_root('ext_coffee/test/fixtures/files/turbolinks')
  for (const event_name of events) {
    addEventListener(event_name, (event) => {
      window.events_log.push([event.type, event.data])
    }, false)
  }
})

afterAll(() => {
  fixture.reset_root()
})

beforeEach(() => {
  window.events_log = []
  xhr.setup()
})

afterEach(() => {
  xhr.teardown()
})

const old_click_bubbled = Turbolinks.controller.click_bubbled.bind(Turbolinks.controller)
Turbolinks.controller.click_bubbled = function (event) {
  let bubbled = !!old_click_bubbled(event)
  event.data = { bubbled }
  Turbolinks.dispatch('turbolinks:click-only', event)
}

const old_visit = Turbolinks.controller.visit.bind(Turbolinks.controller)
Turbolinks.controller.visit = function (location, options = {}) {
  if (branches.click_only) {
    return true
  } else if (branches.visit_reload) {
    let result = old_visit(location, options)
    Turbolinks.dispatch('turbolinks:visit-reload', { data: { url: new URL(location).toString() } })
    return result
  } else if (branches.click_cancel) {
    let prevented = !old_visit(location, options)
    Turbolinks.dispatch('turbolinks:click-cancel', { data: { prevented } })
    return prevented
  } else {
    return old_visit(location, options)
  }
}

function listen_on(event_name, handler) {
  addEventListener(event_name, function eventListener(event) {
    removeEventListener(event_name, eventListener, false)
    handler(event)
  }, false)
}

function navigate(direction, location, { event_name = 'turbolinks:load' } = {}, asserts) {
  return new Promise((resolve) => {
    listen_on(event_name, (event) => {
      resolve(event)
      asserts(event)
    })
    return window.history[direction]()
  })
}

const turbolinks = {
  setup: (location, { async = false } = {}) => {
    let state = { turbolinks: { restorationIdentifier: Turbolinks.controller.restorationIdentifier } }
    window.history.replaceState(state, null, `/${location}`)
    Turbolinks.controller.location = Turbolinks.Location.wrap(window.location)
    window.setup_document(fixture.html(location))
    Turbolinks.clearCache()
    if (!async) {
      Turbolinks.dispatch('DOMContentLoaded')
    }
  },
  back: (...args) => {
    return navigate('back', ...args)
  },
  forward: (...args) => {
    return navigate('forward', ...args)
  },
  visit_reload_and_assert: (url) => {
    assert.total(4)
    assert.null(window.location)
    turbolinks.on_event('turbolinks:before-visit', (event) => {
      assert.equal(url, event.data.url)
    })
    turbolinks.visit_reload(url, (event) => {
      assert.equal(url, event.data.url)
      assert.equal(url, window.location.toString())
    })
  },
  visit_reload: (location, asserts) => {
    return new Promise((resolve) => {
      listen_on('turbolinks:visit-reload', (event) => {
        branches.visit_reload = false
        resolve(event)
        asserts(event)
      })
      branches.visit_reload = true
      return Turbolinks.visit(location)
    })
  },
  visit: (location, { event_name = 'turbolinks:load', status = 200, action = 'advance' } = {}, asserts) => {
    let origin_url = `http://localhost/${location}`
    xhr.get(origin_url, (req, res) => {
      return res.status(status).header('content-type', 'text/html').body(fixture.html(location))
    })
    return new Promise((resolve) => {
      listen_on(event_name, (event) => {
        resolve(event)
        asserts(event)
      })
      return Turbolinks.visit(location, { action })
    })
  },
  click_cancel: (selector, asserts) => {
    let link = document.querySelector(selector)
    return new Promise((resolve) => {
      listen_on('turbolinks:click-cancel', (event) => {
        branches.click_cancel = false
        resolve(event)
        asserts(event)
      })
      branches.click_cancel = true
      return link.click()
    })
  },
  click_only: (selector, asserts) => {
    let link = document.querySelector(selector)
    return new Promise((resolve) => {
      listen_on('turbolinks:click-only', (event) => {
        branches.click_only = false
        resolve(event)
        asserts(event)
      })
      branches.click_only = true
      return Turbolinks.dispatch('click', { target: link, cancelable: true })
    })
  },
  click_reload: (selector, asserts) => {
    let responded = false
    turbolinks.on_event('turbolinks:request-end', (event) => {
      responded = true
    })
    let rendered = false
    turbolinks.on_event('turbolinks:render', (event) => {
      rendered = true
    })
    return turbolinks.click(selector, {}, (event) => {
      event.responded = responded
      event.rendered = rendered
      asserts(event)
    })
  },
  click: (selector, { event_name = 'turbolinks:load', status = 200 } = {}, asserts) => {
    let link = document.querySelector(selector)
    let origin_url = link.href
    let anchor = origin_url.split('#')[1]
    if (anchor != null) {
      origin_url = origin_url.replace(`#${anchor}`, '')
    }
    let location = origin_url.replace(/^http:\/\/localhost\//, '')
    xhr.get(origin_url, (req, res) => {
      return res.status(status).header('content-type', 'text/html').body(fixture.html(location))
    })
    return new Promise((resolve) => {
      listen_on(event_name, (event) => {
        resolve(event)
        asserts(event)
      })
      return link.click()
    })
  },
  on_event: (event_name, asserts = (e) => {}) => {
    listen_on(event_name, (event) => {
      asserts(event)
    })
  },
  assert_reload: (event, href, { action = 'advance' } = {}) => {
    assert.true(event.responded)
    assert.false(event.rendered)
    assert.equal(action, Turbolinks.controller.current_visit.action)
    assert.equal(href, event.data.url)
    assert.called(window.location.reload)
  },
  assert_page: (event, href, { title, h1 = title, action = 'advance' } = {}) => {
    let anchor = href.split('#')[1]
    if (anchor) {
      assert.called(Element.prototype.scrollIntoView)
    } else {
      assert.called(window.scrollTo)
    }
    assert.equal(action, Turbolinks.controller.current_visit.action)
    assert.equal(href, event.data.url)
    assert.equal(href, window.location.href)
    assert.equal(title, document.querySelector('title').innerHTML)
    assert.equal(h1, document.querySelector('h1').innerHTML)
  },
  assert_click_event: (event, { bubbled }) => {
    assert.equal(bubbled, event.data.bubbled)
  },
}

module.exports = turbolinks
