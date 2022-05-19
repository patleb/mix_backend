import turbolinks from './spec_helper'

describe('Turbolinks Rendering', () => {
  beforeEach(() => {
    turbolinks.setup('rendering')
  })

  afterEach(() => {
    dom.reset_document()
  })

  it('should go to location /rendering', async () => {
    await turbolinks.visit('rendering', {}, (event) => {
      turbolinks.assert_page(event, 'http://localhost/rendering', { title: 'Turbolinks', h1: 'Rendering' })
    })
  })

  it('should trigger before-render and render events', async () => {
    assert.total(4)
    let new_body
    turbolinks.on_event('turbolinks:before-render', {}, (event) => {
      new_body = event.data.new_body
      assert.not_equal(document.body.innerHTML, new_body.innerHTML)
      assert.equal('One', new_body.querySelector('h1').innerHTML)
    })
    turbolinks.on_event('turbolinks:render', {}, (event) => {
      assert.equal(document.body.innerHTML, new_body.innerHTML)
    })
    await turbolinks.click('#same-origin-link', {}, (event) => {
      assert.not_null(event)
    })
  })

  it('should trigger before-render and render events for error pages', async () => {
    assert.total(3)
    let new_body
    turbolinks.on_event('turbolinks:before-render', {}, (event) => {
      new_body = event.data.new_body
      assert.not_equal(document.body.innerHTML, new_body.innerHTML)
    })
    turbolinks.on_event('turbolinks:render', {}, (event) => {
      assert.equal(document.body.innerHTML, new_body.innerHTML)
    })
    await turbolinks.click('#nonexistent-link', { event_name: 'turbolinks:render', status: 404 }, (event) => {
      assert.equal('Not found', document.body.innerHTML.trim())
    })
  })

  describe('Reload', () => {
    beforeAll(() => {
      url.mock_location()
    })

    afterAll(() => {
      url.reset_location()
    })

    it('should reload when tracked elements change', async () => {
      await turbolinks.click_reload('#tracked-asset-change-link', (event) => {
        turbolinks.assert_reload(event, 'http://localhost/tracked_asset_change')
      })
    })

    it('should reload when turbolinks-visit-control setting is reload', async () => {
      await turbolinks.click_reload('#visit-control-reload-link', (event) => {
        turbolinks.assert_reload(event, 'http://localhost/visit_control_reload')
      })
    })
  })

  it('should not scroll when turbolinks-visit-control setting is no-scroll', async () => {
    assert.total(2)
    await turbolinks.click('#visit-control-no-scroll-link', {}, (event) => {
      assert.not_called(window.scrollTo)
      assert.equal('http://localhost/visit_control_no_scroll', event.data.url)
    })
  })

  it('should accumulate asset elements in head', async () => {
    assert.total(2)
    let old_elements = get_asset_elements()
    let new_elements
    await turbolinks.click('#additional-assets-link', { event_name: 'turbolinks:render' }, (event) => {
      new_elements = get_asset_elements()
      assert.not_equal(old_elements, new_elements)
    })
    await turbolinks.back({ event_name: 'turbolinks:render' }, (event) => {
      old_elements = get_asset_elements()
      assert.equal(new_elements, old_elements)
    })
  })

  it('should replace provisional elements in head', async () => {
    assert.null(document.querySelector('meta[name=test]'))
    let old_elements = get_provisional_elements()
    let new_elements
    await turbolinks.click('#same-origin-link', { event_name: 'turbolinks:render' }, (event) => {
      new_elements = get_provisional_elements()
      assert.not_equal(old_elements, new_elements)
      assert.not_null(document.querySelector('meta[name=test]'))
    })
    await turbolinks.back({ event_name: 'turbolinks:render' }, (event) => {
      old_elements = get_provisional_elements()
      assert.not_equal(new_elements, old_elements)
      assert.null(document.querySelector('meta[name=test]'))
    })
  })

  it('should evaluate head script elements once', async () => {
    assert.null(window.headScriptEvaluationCount)
    await turbolinks.click('#head-script-link', { event_name: 'turbolinks:render' }, (event) => {
      assert.equal(1, window.headScriptEvaluationCount)
    })
    await turbolinks.back({ event_name: 'turbolinks:render' }, (event) => {
      assert.equal(1, window.headScriptEvaluationCount)
    })
    await turbolinks.click('#head-script-link', { event_name: 'turbolinks:render' }, (event) => {
      assert.equal(1, window.headScriptEvaluationCount)
    })
    delete window.headScriptEvaluationCount
  })

  it('should evaluate body script elements on each render', async () => {
    assert.null(window.bodyScriptEvaluationCount)
    await turbolinks.click('#body-script-link', { event_name: 'turbolinks:render' }, (event) => {
      assert.equal(1, window.bodyScriptEvaluationCount)
    })
    await turbolinks.back({ event_name: 'turbolinks:render' }, (event) => {
      assert.equal(1, window.bodyScriptEvaluationCount)
    })
    await turbolinks.click('#body-script-link', { event_name: 'turbolinks:render' }, (event) => {
      assert.equal(2, window.bodyScriptEvaluationCount)
    })
    delete window.bodyScriptEvaluationCount
  })

  it('should not evaluate data-turbolinks-eval=false scripts', async () => {
    assert.null(window.bodyScriptEvaluationCount)
    await turbolinks.click('#eval-false-script-link', { event_name: 'turbolinks:render' }, (event) => {
      assert.null(window.bodyScriptEvaluationCount)
    })
  })

  it('should preserve permanent elements', async () => {
    assert.total(3)
    let old_element = document.querySelector('#permanent')
    let new_element
    assert.equal('Rendering', old_element.innerHTML)
    await turbolinks.click('#permanent-element-link', { event_name: 'turbolinks:render' }, (event) => {
      new_element = document.querySelector('#permanent')
      assert.same(old_element, new_element)
    })
    await turbolinks.back({ event_name: 'turbolinks:render' }, (event) => {
      new_element = document.querySelector('#permanent')
      assert.same(old_element, new_element)
    })
  })

  it('should trigger before-cache event', async () => {
    turbolinks.on_event('turbolinks:before-cache', {}, (event) => {
      document.body.innerHTML = 'Modified'
    })
    await turbolinks.click('#same-origin-link', {}, (event) => {
      assert.not_equal('Modified', document.body.innerHTML)
    })
    await turbolinks.back({}, (event) => {
      assert.equal('Modified', document.body.innerHTML)
    })
  })

  it('should mutate record on before-cache notification', async () => {
    const { documentElement, body } = document
    const observer = new MutationObserver(records => {
      for (const record of records) {
        if (Array.from(record.removedNodes).indexOf(body) > -1) {
          body.innerHTML = "Modified"
          observer.disconnect()
          break
        }
      }
    })
    observer.observe(documentElement, { childList: true })
    await turbolinks.click('#same-origin-link', {}, (event) => {
      assert.not_equal('Modified', document.body.innerHTML)
    })
    await turbolinks.back({}, (event) => {
      assert.equal('Modified', document.body.innerHTML)
    })
  })

  it('should render the specified body container marked with data-turbolinks-body', async () => {
    await turbolinks.click('#body-container', {}, (event) => {
      assert.includes('Rendering', document.body.innerHTML)
      assert.excludes('Body container', document.body.innerHTML)
      assert.includes('New body', document.body.innerHTML)
    })
  })

  it('should load error pages', async () => {
    await turbolinks.click('#nonexistent-link', { event_name: 'turbolinks:render', status: 404 }, (event) => {
      assert.equal('Not found', document.body.innerHTML.trim())
    })
  })

  describe('No defer', () => {
    beforeEach(() => {
      turbolinks.setup_no_defer()
    })

    afterEach(() => {
      turbolinks.reset_defer()
    })

    it('should load the preview before the new page', async () => {
      await turbolinks.visit('one', {}, (event) => {
        assert.equal(1, Turbolinks.controller.cache.keys.length)
      })
      turbolinks.on_event('turbolinks:before-render', { event_count: 2 }, (event, index) => {
        assert.equal(2, Turbolinks.controller.cache.keys.length)
        if (index === 0) {
          assert.true(event.data.preview)
        } else {
          assert.false(event.data.preview)
        }
      })
      await turbolinks.visit('rendering', {}, (event) => {
        assert.equal(2, Turbolinks.controller.cache.keys.length)
      })
    })

    it('should not preview when replacing the current location', async () => {
      await turbolinks.visit('rendering', {}, (event) => {
        assert.equal(1, Turbolinks.controller.cache.keys.length)
      })
      turbolinks.on_event('turbolinks:before-render', {}, (event) => {
        assert.equal(1, Turbolinks.controller.cache.keys.length)
        assert.false(event.data.preview)
      })
      await turbolinks.visit('rendering', { action: 'replace' }, (event) => {
        assert.equal(1, Turbolinks.controller.cache.keys.length)
      })
    })
  })
})

const get_asset_elements = () => {
  return dom.children(document.head, (e) => dom.matches(e, 'script, style, link[rel=stylesheet], noscript'))
}
const get_provisional_elements = () => {
  return dom.children(document.head, (e) => !dom.matches(e, 'script, style, link[rel=stylesheet], noscript'))
}
