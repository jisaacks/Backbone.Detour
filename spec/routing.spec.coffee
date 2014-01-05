# Include required libraries
global._        = require("underscore")
global.Backbone = require("backbone")
sinon           = require("sinon")
stubber         = require("backbone.history_stub")

# Require the module
require("../lib/backbone.detour")

# Stub so we can use Backbone.history without a browser
stubber.stub()

# Create spy to keep an eye on our router
spy = sinon.spy()

# Convenience method for grabbing values passed to handleRoute
spyarg = (name) -> spy.lastCall.args[0][name]

# Extend Backbone.Detour for our sepcs
class SpecRouter extends Backbone.Detour
  routeOptions: ->
    @optional 'page', default: '1'
  handleRoute: (args) -> 
    spy(args)
  reset: ->
    @previousValues = null
    @paramsForRoute = []
    @routeOptions()

# Create an instance
router = new SpecRouter()

# Startup history
Backbone.history.start()

# OK enough taking, lets start testing.
describe "Routing", ->

  beforeEach ->
    router.reset()
    spy.reset()

  #-

  it "calls handleRoute", ->
    router.updateRoute page: '99'
    expect(spy.called).toBe(true)

  #-

  it "passes the correct args to handleRoute", ->
    router.updateRoute page:'2'
    expect(spyarg 'page').toEqual('2')
    
  #-

  it "falls back to default when passed false", ->
    router.updateRoute page:'100'
    router.updateRoute page:false
    expect(spyarg 'page').toEqual('1')

  #-

  it "works with spaces in values", ->
    router.optional 'full_name'
    router.updateRoute full_name:'JD Isaacks'
    expect(spyarg 'full_name').toEqual('JD Isaacks')

  #-

  it "works with arrays", ->
    router.optional 'list', type:'array'
    router.updateRoute list:['foo','bar']
    expect(spyarg 'list').toEqual(['foo','bar'])

  #-

  it "does not append by default", ->
    router.optional 'list', type:'array'
    router.updateRoute list:['foo']
    router.updateRoute list:['bar']
    expect(spyarg 'list').toEqual(['bar'])

  #-

  it "does append when set to", ->
    router.optional 'list', type:'array', append:true
    router.updateRoute list:['foo']
    router.updateRoute list:['bar']
    expect(spyarg 'list').toEqual(['bar','foo'])

  #-

  it "does not append more than appendLimit", ->
    router.optional 'list', type:'array', append:true, appendLimit:3
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['c']
    router.updateRoute list:['d']
    expect(spyarg 'list').toEqual(['d','c','b'])

  #-

  it "does not unique array values by default", ->
    router.optional 'list', type:'array', append:true
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['a']
    expect(spyarg 'list').toEqual(['a','b','a'])

  #-

  it "does unique array values when set to", ->
    router.optional 'list', type:'array', append:true, unique:true
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['a']
    expect(spyarg 'list').toEqual(['a','b'])

  #-

  it "clears others specified to be cleared", ->
    router.optional 'banana'
    router.optional 'apple', clears:'banana'
    router.updateRoute banana:'3'
    expect(spyarg 'banana').toEqual('3')
    router.updateRoute page:'4'
    expect(spyarg 'banana').toEqual('3')
    router.updateRoute apple:'2'
    expect(spyarg 'banana').toEqual(undefined)

  it "sets a param to default if cleared", ->
    router.optional 'filter', clears:'page'
    router.updateRoute page:'2'
    expect(spyarg 'page').toEqual('2')
    router.updateRoute filter:'cool'
    expect(spyarg 'page').toEqual('1')

Backbone.history.stop()