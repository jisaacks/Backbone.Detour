class Backbone.Detour extends Backbone.Router

  # private api -----

  routes:
    '*path' : 'routeHandler'

  #--

  routeHandler: (route) ->
    args   = @parseRoute(route)
    _.each @paramsForRoute, (pfr) =>
      val = args[pfr.name]
      val = val?.split?(',') or val if pfr.type?.toLowerCase() == 'array'
      args[pfr.name] = val
    @previousValues = {} unless @previousValues
    _.each args, (v,k) => @previousValues[k] = v
    @handleRoute args

  #--

  parseRoute: (route) ->
    # build the paramsForRoute array
    unless @paramsForRoute?
      @paramsForRoute = []
      @routeOptions()
    
    # build arg object from route
    keys = []
    vals = []
    
    if route
      _.each route.split('/'), (v,i) ->
        (if i % 2 == 0 then keys else vals).push v
    
    vals = _.map vals, (val) -> decodeURI(val)
    o = _.object(keys,vals)
    
    # set defaults
    _.each @paramsForRoute, (opt) ->
      if opt.default?
        o[opt.name] = (opt.default?()||opt.default) unless o[opt.name]
    o

  #--

  buildRoute: (opts={}) ->
    # build all options
    options = {}
    @previousValues = {} unless @previousValues 
    _.each @paramsForRoute, (pfr) =>
      prevVal = @previousValues[pfr.name]
      val = if opts[pfr.name] == false
        # passed as false, try to use default
        (pfr.default?()||pfr.default) or false
      else if opts[pfr.name]
        # passed as something other than false, use it
        opts[pfr.name]
      else
        # not passed, use prev value or default or false
        prevVal or (pfr.default?()||pfr.default) or false
      
      if pfr.squash? && val == pfr.squash
        val = false

      if pfr.group
        # see if it was just set
        if val && !prevVal
          # this value was just set for this group
          # clear all other params of the same group
          grouped = _.filter @paramsForRoute, (other_pfr) ->
            other_pfr.group == pfr.group && other_pfr.name != pfr.name
          _.each grouped, (member) -> 
            # clear it from the opts
            opts[member.name] = false
            # it may have already been set to options,
            # so clear it from there too.
            options[member.name] = false

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
    r

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


  # to be overridden ---


  routeOptions: ->

  #--

  handleRoute: (args) ->

  #----------------------