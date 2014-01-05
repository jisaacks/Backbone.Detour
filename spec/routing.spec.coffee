# include reauired libraries
GLOBAL.window   = {location: ''}
GLOBAL._        = require("underscore")
GLOBAL.Backbone = require("backbone")
sinon           = require("sinon")

require("../lib/backbone.detour")

describe "Routing", ->
  
  # setup
  class TestRouter extends Backbone.Detour
    routeOptions: ->
      @optional 'page', default: '1'
  
  router = null
  spy = null
  try
    Backbone.history.start()
  catch e

  beforeEach ->
    spy = sinon.spy()
    router = new TestRouter()
    router.updateRoute() # simulates the initial call (when page loads)
    router.handleRoute = (args) -> 
      # console.log('ARGS', args);
      spy(args)

  #-

  it "calls handleRoute", ->
    router.updateRoute()
    expect(spy.calledOnce).toBe(true)
    expect(spy.callCount).toBe(1)

  #-

  it "passes the correct args to handleRoute", ->
    router.updateRoute page:2
    expect(spy.lastCall.args).toEqual([page:'2'])
    
  #-

  it "falls back to default when passed false", ->
    router.updateRoute page:100
    router.updateRoute page:false
    expect(spy.lastCall.args).toEqual([page:'1'])

  #-

  it "works with spaces in values", ->
    router.optional 'full_name'
    router.updateRoute full_name:'JD Isaacks'
    expect(spy.lastCall.args).toEqual([full_name:'JD Isaacks',page:'1'])

  #-

  it "works with arrays", ->
    router.optional 'list', type:'array'
    router.updateRoute list:['foo','bar']
    expect(spy.lastCall.args).toEqual([list:['foo','bar'],page:'1'])

  #-

  it "does not append by default", ->
    router.optional 'list', type:'array'
    router.updateRoute list:['foo']
    router.updateRoute list:['bar']
    expect(spy.lastCall.args).toEqual([list:['bar'],page:'1'])

  #-

  it "does append when set to", ->
    router.optional 'list', type:'array', append:true
    router.updateRoute list:['foo']
    router.updateRoute list:['bar']
    expect(spy.lastCall.args).toEqual([list:['bar','foo'],page:'1'])

  #-

  it "does not append more than appendLimit", ->
    router.optional 'list', type:'array', append:true, appendLimit:3
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['c']
    router.updateRoute list:['d']
    expect(spy.lastCall.args).toEqual([list:['d','c','b'],page:'1'])

  #-

  it "does not unique array values by default", ->
    router.optional 'list', type:'array', append:true
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['a']
    expect(spy.lastCall.args).toEqual([list:['a','b','a'],page:'1'])

  #-

  it "does unique array values when set to", ->
    router.optional 'list', type:'array', append:true, unique:true
    router.updateRoute list:['a']
    router.updateRoute list:['b']
    router.updateRoute list:['a']
    expect(spy.lastCall.args).toEqual([list:['a','b'],page:'1'])

  #-

  it "clears others specified to be cleared", ->
    router.optional 'banana'
    router.optional 'apple', clears:'banana'
    router.updateRoute banana:'3'
    expect(spy.lastCall.args).toEqual([banana:'3',page:'1'])
    router.updateRoute page:'4'
    expect(spy.lastCall.args).toEqual([banana:'3',page:'4'])
    router.updateRoute apple:'2'
    expect(spy.lastCall.args).toEqual([apple:'2',page:'4'])

  it "sets a param to default if cleared", ->
    router.optional 'filter', clears:'page'
    router.updateRoute page:'2'
    expect(spy.lastCall.args).toEqual([page:'2'])
    router.updateRoute filter:'cool'
    expect(spy.lastCall.args).toEqual([filter:'cool',page:'1'])
