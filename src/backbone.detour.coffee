class Backbone.Detour extends Backbone.Router

  # private api -----

  routes:
    '*path' : 'routeHandler'

  #--

  routeHandler: (route) ->
    parsed = @parseRoute(route)
    args   = parsed[0]
    toks   = parsed[1]
    _.each @paramsForRoute, (pfr) =>
      val = args[pfr.name]
      val = val?.split?(',') or val if pfr.type?.toLowerCase() == 'array'
      args[pfr.name] = val
    @previousValues = {} unless @previousValues
    _.each args, (v,k) => @previousValues[k] = v
    @handleRoute args, toks

  #--

  parseRoute: (route) ->
    # build the paramsForRoute array
    unless @paramsForRoute?
      @paramsForRoute = []
      @expectedTokens = []
      @routeOptions()
    
    # build arg object from route
    keys = []
    vals = []
    toks = []
    if route
      tokens = route.split('/')
      # search for expected tokens
      _.each tokens, (t) =>
        toks.push t if t in @expectedTokens
      # strip found toks out of tokens
      values = _.without tokens, toks...
      # convert remaining tokens into key value pairs
      _.each values, (v,i) ->
        (if i % 2 == 0 then keys else vals).push v
    o = _.object(keys,vals)
    
    # set defaults
    _.each @paramsForRoute, (opt) ->
      if opt.default
        o[opt.name] = opt.default unless o[opt.name]
    [o, toks]

  #--

  buildRoute: (opts={}) ->
    # extract tokens
    if opts.tokens
      @previousTokens = opts.tokens
      tokens = opts.tokens.join('/')+'/'
    else if @previousTokens
      tokens = @previousTokens.join('/')+'/'
    else
      tokens = ''
    opts = _.omit opts, 'tokens'
    # build all options
    options = {}
    @previousValues = {} unless @previousValues 
    _.each @paramsForRoute, (pfr) =>
      prevVal = @previousValues[pfr.name]
      val = if opts[pfr.name] == false
        # passed as false, try to use default
        pfr.default or false
      else if opts[pfr.name]
        # passed as something other than false, use it
        opts[pfr.name]
      else
        # not passed, use prev value or default or false
        prevVal or pfr.default or false
      if val && pfr.type?.toLowerCase() == 'array' && pfr.append
        vals = val
        prevVals = prevVal or []
        for pv in prevVals
          unless vals.length == (pfr.appendLimit or 99)
            if pfr.unique
              comparator = pfr.comparator || (a,b) -> a == b
              vals.push pv unless true in _.map vals, (val) -> comparator(val, pv)
            else
              vals.push pv
        val = vals.join?(',')
      options[pfr.name] = val

    # get required options
    required = _.filter @paramsForRoute, (opt) -> opt.required
    # see if any required options are not set
    requiredNotSet = false in (_.map required, (req) => options[req.name] or false)
    if requiredNotSet
      r = ''
    else
      rs = []
      _.each @paramsForRoute, (pfr) =>
        # add option to route if it is set
        rs.push "#{pfr.name}/#{encodeURI(options[pfr.name])}" if options[pfr.name]
      r = rs.join "/"
    tokens+r

  # public api -----

  updateRoute: (opts) ->
    @navigate @buildRoute(opts), trigger: true

  #--

  optional: (name, opts={}) ->
    opts.name = name
    @paramsForRoute.push opts

  required: (name, opts={}) ->
    opts.name = name
    opts.required = true
    @paramsForRoute.push opts

  tokens: (list...) ->
    @expectedTokens or= []
    @expectedTokens.push list
    @expectedTokens = _.uniq _.flatten @expectedTokens


  # to be overridden ---


  routeOptions: ->

  #--

  handleRoute: (args) ->

  #----------------------