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

# Create an instance
router = new SpecRouter()

# Startup history
Backbone.history.start()

# OK enough taking, lets start testing.
describe "Routing", ->

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
    expect(spy.lastCall.args[0].list).toEqual(['foo','bar'])

  #-

  it "does not append by default", ->
    router.optional 'unappenedList', type:'array'
    router.updateRoute unappenedList:['foo']
    router.updateRoute unappenedList:['bar']
    expect(spy.lastCall.args[0].unappenedList).toEqual(['bar'])

  #-

  it "does append when set to", ->
    router.optional 'appenedList', type:'array', append:true
    router.updateRoute appenedList:['foo']
    router.updateRoute appenedList:['bar']
    expect(spy.lastCall.args[0].appenedList).toEqual(['bar','foo'])

  #-

  it "does not append more than appendLimit", ->
    router.optional 'limitedList', type:'array', append:true, appendLimit:3
    router.updateRoute limitedList:['a']
    router.updateRoute limitedList:['b']
    router.updateRoute limitedList:['c']
    router.updateRoute limitedList:['d']
    expect(spy.lastCall.args[0].limitedList).toEqual(['d','c','b'])

  #-

  it "does not unique array values by default", ->
    router.optional 'dupList', type:'array', append:true
    router.updateRoute dupList:['a']
    router.updateRoute dupList:['b']
    router.updateRoute dupList:['a']
    expect(spy.lastCall.args[0].dupList).toEqual(['a','b','a'])

  #-

  it "does unique array values when set to", ->
    router.optional 'uniqList', type:'array', append:true, unique:true
    router.updateRoute uniqList:['a']
    router.updateRoute uniqList:['b']
    router.updateRoute uniqList:['a']
    expect(spy.lastCall.args[0].uniqList).toEqual(['a','b'])

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