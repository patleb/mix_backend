import rails from './spec_helper'

describe('Rails UJS Helpers', () => {
  beforeEach(() => {
    dom.setup_document(fixture.html('helpers'))
  })

  afterEach(() => {
    dom.reset_document()
  })

  it('should have the getter for a href element overridable', async () => {
    const old_href = Rails.href
    Rails.href = (element) => element.getAttribute('data-href')
    await rails.click('#fixture a', { 'ajax:beforeSend': (event) => {
      event.preventDefault()
      assert.equal('/data/href', event.detail[1].url)
    }})
    Rails.href = old_href
  })

  it('should have the getter for a href work normally if not overridden', async () => {
    await rails.click('#fixture a', { 'ajax:beforeSend': (event) => {
      event.preventDefault()
      assert.equal('http://localhost/real/href', event.detail[1].url)
    }})
  })

  it('should have the event selector strings overridable', () => {
    assert.includes(', a[data-custom-remote-link]', Rails.click_links)
  })

  it('should throw error when including rails-ujs multiple times', () => {
    assert.raise(Error, Rails.start)
  })

  it('should find the csrf token', () => {
    assert.equal('cf50faa3fe97702ca1ae', Rails.csrf_token())
  })

  it('should find the csrf param', () => {
    assert.equal('authenticity_token', Rails.csrf_param())
  })

  it('should refresh all csrf tokens', () => {
    assert.equal('foo', document.querySelector('#authenticity_token').value)
    Rails.fire(document, 'DOMContentLoaded')
    assert.equal('cf50faa3fe97702ca1ae', document.querySelector('#authenticity_token').value)
  })

  it('should call ajax without "ajax:beforeSend"', async () => {
    let before = false
    dom.on_event({ 'ajax:beforeSend': (event) => {
      before = true
    }})
    await rails.ajax('get', '/', { 'complete': (xhr) => {
      assert.false(before)
      assert.equal(200, xhr.status)
    }})
    dom.off_event('ajax:beforeSend')
  })
})
