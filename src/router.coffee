class @Router extends Backbone.Detour
  initialize: (args) ->

  routeOptions: ->
    @optional 'section', default: 'intro'

  classify: (str) ->
    str.charAt(0).toUpperCase() + str.slice(1)

  handleRoute: (args) ->
    view = Views[@classify args.section]
    if view
      $('body').html new view().render(@prev).el
      @prev = "#section/#{args.section}"
      console.log @prev