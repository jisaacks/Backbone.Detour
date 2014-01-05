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

  #-

  it "calls handleRoute", ->
    router.updateRoute page: '99'
    expect(spy.called).toBe(true)

  #-

  it "passes the correct args to handleRoute", ->
    router.updateRoute page:'2'
    expect(spy.lastCall.args[0].page).toEqual('2')
    
  #-

  it "falls back to default when passed false", ->
    router.updateRoute page:'100'
    router.updateRoute page:false
    expect(spy.lastCall.args[0].page).toEqual('1')

  #-

  it "works with spaces in values", ->
    router.optional 'full_name'
    router.updateRoute full_name:'JD Isaacks'
    expect(spy.lastCall.args[0].full_name).toEqual('JD Isaacks')

  #-

  it "works with arrays", ->
    router.optional 'list', type:'array'
    router.updateRoute list:['foo','bar']
    expect(spy.lastCall.args[0].list).toEqual(['foo','bar'])

  #-

  it "does not append by default", ->
    router.optional 'list', type:'array'
    router.updateRoute list:['foo']
    router.updateRoute list:['bar']
    expect(spy.lastCall.args[0].list).toEqual(['bar'])

  #-

  it "does append when set to", ->
    router.optional 'list', type:'array', append:true
    router.updateRoute list:['foo']
    router.updateRoute list:['bar']
    expect(spy.lastCall.args[0].list).toEqual(['bar','foo'])

  #-

  it "does not append more than appendLimit", ->
    router.optional 'list', type:'array', append:true, appendLimit:3
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['c']
    router.updateRoute list:['d']
    expect(spy.lastCall.args[0].list).toEqual(['d','c','b'])

  #-

  it "does not unique array values by default", ->
    router.optional 'list', type:'array', append:true
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['a']
    expect(spy.lastCall.args[0].list).toEqual(['a','b','a'])

  #-

  it "does unique array values when set to", ->
    router.optional 'list', type:'array', append:true, unique:true
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['a']
    expect(spy.lastCall.args[0].list).toEqual(['a','b'])

  #-

  it "clears others specified to be cleared", ->
    router.optional 'banana'
    router.optional 'apple', clears:'banana'
    router.updateRoute banana:'3'
    expect(spy.lastCall.args[0].banana).toEqual('3')
    router.updateRoute page:'4'
    expect(spy.lastCall.args[0].banana).toEqual('3')
    router.updateRoute apple:'2'
    expect(spy.lastCall.args[0].banana).toEqual(undefined)

  it "sets a param to default if cleared", ->
    router.optional 'filter', clears:'page'
    router.updateRoute page:'2'
    expect(spy.lastCall.args[0].page).toEqual('2')
    router.updateRoute filter:'cool'
    expect(spy.lastCall.args[0].page).toEqual('1')

Backbone.history.stop()