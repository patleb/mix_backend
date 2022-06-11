import './spec_helper'

describe('Js.Concepts', () => {
  beforeAll(() => {
    dom.setup_document(fixture.html('concepts', { root: 'ext_coffee/test/fixtures/files/js' }))
    Js.Concepts.initialize({ modules: ['Test'], concepts: ['Test.SimpleConcept'] })
  })

  afterAll(() => {
    dom.reset_document()
  })

  it('should create all concept instances', () => {
    assert.equal(1, Js.Concepts.instances.ready_once.length)
    assert.equal(1, Js.Concepts.instances.ready.length)
    assert.equal(1, Js.Concepts.instances.leave.length)
    assert.equal(4, Js.Concepts.instances.leave_clean.length)
    assert.equal('Test', Test.SimpleConcept.module_name)
    assert.equal('SimpleConcept', Test.SimpleConcept.class_name)
    assert.false(Test.SimpleConcept.is_a(Function))
    assert.true(Test.NotAConceptName.is_a(Function))
    assert.same(Global, Test.GlobalConcept)
    assert.same(SomeGlobal, Test.CustomGlobalConcept)
    const constants = {
      BODY:      '#js_simple_body',
      ROWS:      '.js_simple_rows',
      TRIGGERED: 'js_simple_triggered',
      CUSTOM:    '.js_simple_custom > a',
      BODY_ROWS: '#js_simple_body .js_simple_rows',
    }
    assert.equal(constants, Test.SimpleConcept.constructor.prototype.CONSTANTS)
    constants.each((name, value) => {
      assert.equal(value, Test.SimpleConcept[name])
    })
  })

  it('should call #ready_once and #ready on "DOMContentLoaded"', async () => {
    dom.fire('DOMContentLoaded')
    dom.fire('turbolinks:load', { data: { info: { once: true } } })
    await tick()
    assert.equal(1, Test.SimpleConcept.did_ready_once)
    assert.equal(1, Test.SimpleConcept.did_ready)
    assert.null(Test.SimpleConcept.__did_leave)
  })

  it('should call #ready on "turbolinks:load"', () => {
    dom.fire('turbolinks:load', { data: { info: {} } })
    assert.equal(1, Test.SimpleConcept.did_ready_once)
    assert.equal(2, Test.SimpleConcept.did_ready)
    assert.null(Test.SimpleConcept.__did_leave)
  })

  it('should call #leave on "turbolinks:before-render" and nullify #did_ready ivar', () => {
    dom.fire('turbolinks:before-render')
    assert.equal(1, Test.SimpleConcept.did_ready_once)
    assert.null(Test.SimpleConcept.did_ready)
    assert.equal(1, Test.SimpleConcept.__did_leave)
  })

  it('should define lazy #accessors', () => {
    assert.null(Test.SimpleConcept.__rows)
    dom.$0(Test.SimpleConcept.BODY).click()
    assert.equal(Test.SimpleConcept.__rows, Test.SimpleConcept.rows())
  })

  it('should nullify non-system ivars and not from #ready_once on #leave', () => {
    assert.equal('method', Test.SimpleConcept.method())
    assert.equal('constant', Test.SimpleConcept.CONSTANT)
    assert.equal('public', Test.SimpleConcept.public)
    assert.equal('private', Test.SimpleConcept._private)
    assert.equal('system', Test.SimpleConcept.__system)
    assert.equal('inherited', Test.ExtendConcept.inherited)
    dom.fire('turbolinks:before-render')
    assert.null(Test.SimpleConcept.__rows)
    assert.not_null(Test.SimpleConcept.method)
    assert.not_null(Test.SimpleConcept.CONSTANT)
    assert.null(Test.SimpleConcept.public)
    assert.null(Test.SimpleConcept._private)
    assert.not_null(Test.SimpleConcept.__system)
    assert.null(Test.ExtendConcept.inherited)
  })

  describe('#document_on', () => {
    afterEach(() => {
      dom.$0(Test.SimpleConcept.BODY).remove_class(Test.SimpleConcept.TRIGGERED)
      dom.$(Test.SimpleConcept.ROWS).each(e => e.remove_class(Test.SimpleConcept.TRIGGERED))
    })

    it('should handle click events', () => {
      let row = dom.$0(Test.SimpleConcept.ROWS)
      let event = dom.fire('click', { target: row })
      assert.true(row.classes().include(Test.SimpleConcept.TRIGGERED))
      assert.true(event.document_on_before)
      assert.true(event.document_on_after)
    })

    it('should handle click events and prevent default', () => {
      let body = dom.$0(Test.SimpleConcept.BODY)
      let event = dom.fire('click', { target: body, options: { skip: true } })
      assert.true(body.classes().include(Test.SimpleConcept.TRIGGERED))
      assert.true(event.defaultPrevented)
      assert.true(event.document_on_before)
      assert.null(event.document_on_after)
    })

    it('should handle hover events', () => {
      let row = dom.$0(Test.SimpleConcept.ROWS)
      let event = dom.fire('hover', { target: row })
      assert.true(row.classes().include(Test.SimpleConcept.TRIGGERED))
      assert.true(event.document_on_before)
      assert.true(event.document_on_after)
    })

    it('should skip handler and after hook if prevent default is in before hook', () => {
      let row = dom.$0(Test.SimpleConcept.ROWS)
      let event = dom.fire('hover', { target: row, options: { skip_before: true } })
      assert.true(event.defaultPrevented)
      assert.false(row.classes().include(Test.SimpleConcept.TRIGGERED))
      assert.true(event.document_on_before)
      assert.null(event.document_on_after)
    })

    it('should skip after hook if prevent default is in handler', () => {
      let row = dom.$0(Test.SimpleConcept.ROWS)
      let event = dom.fire('hover', { target: row, options: { skip: true } })
      assert.true(event.defaultPrevented)
      assert.true(row.classes().include(Test.SimpleConcept.TRIGGERED))
      assert.true(event.document_on_before)
      assert.null(event.document_on_after)
    })
  })

  describe('::Element', () => {
    it('should create all element classes', () => {
      assert.equal(Test.SimpleConcept, Test.SimpleConcept.Element.prototype.concept)
      assert.equal('Element', Test.SimpleConcept.Element.class_name)
      assert.equal('js_simple_name', Test.SimpleConcept.Element.prototype.NAME)
    })

    it('should define lazy #accessors and #document_on', () => {
      let body = dom.$0(Test.SimpleConcept.Element.prototype.BODY)
      let event = dom.fire('hover', { target: body })
      assert.true(body.classes().include(Test.SimpleConcept.TRIGGERED))
      assert.equal(Test.SimpleConcept.Element.prototype.__body, Test.SimpleConcept.Element.prototype.body())
      assert.equal(['body'], Test.SimpleConcept.Element.prototype.ACCESSORS)
    })
  })
})
