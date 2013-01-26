# Backbone.Detour

*A different kind of router*

--------------

Normal routing in **Backbone.js** works great for hierarchical routes (e.g. *when you need to drill down to your content.*) However it makes it very cumbersome to use as a *parameter store*.

Lets say you have 3 possible parameters you are listening for: *type*, *date*, and *owner*; and any combination could be present. The normal way to define your routes would be:

```javascript
routes: {
  ""                                   : "someFunction"
  "type/:type"                         : "someFunction"
  "date/:date"                         : "someFunction"
  "owner/:owner"                       : "someFunction"
  "type/:type/date/:date"              : "someFunction"
  "date/:date/owner/:owner"            : "someFunction"
  "type/:type/owner/:owner"            : "someFunction"
  "type/:type/date/:date/owner/:owner" : "someFunction"
}
```
And this requires the order to always be the same. Add a fourth parameter and gets *really long*.

With **Backbone.Detour** the definition would simply be:

```javascript
routeOptions: function() {
  this.optional('type');
  this.optional('date');
  this.optional('owner');
}
```


### Usage

You extend **Backbone.Detour** and define the methods `routeOptions` and `handleRoute` like so:

```javascript
var router = Backbone.Detour.extend({

  routeOptions: function() {
    this.optional('type');
    this.optional('date');
    this.optional('owner');
  },

  handleRoute: function(args) {
    this.type = args.type;
    this.date = args.date;
    this.owner = args.owner;
  }

});
```
You specify what parameters you are expecting in **routeOptions** then any time a route change is triggered, any passed parameters that you are expecting will be available as properties in the object passed to **handleRoute**.

Ok, so lets say you want to update the route and change the value for *owner*. Using the normal:

```javascript
router.navigate('owner/whoever', {trigger: true});
```
would result in whatever you prevously had set for *type* and *date* being cleared. So you would have to keep track of all the values for all the paramters you are *not* changing, just so you could *not change them*:

```javascript
router.navigate('type/'+currentType+'/date/'+currentDate+'/owner/whoever', {trigger: true});
```
For long lists of parameters this would be tedious.

With **Backbone.Detour** you just specify what you want to change:

```javascript
router.updateRoute({owner: 'whoever'});
```

Everything else in the route would stay the same. **But what if I *want* to clear a parameter?** Easy, just set it to false:

```javascript
router.updateRoute({owner: 'whoever', type: false});
```

The above call would update the route to change the **owner** param to *whoever* and clear any value for the **type** parameter if it exists.

[**Check out the extra features**](https://github.com/jisaacks/Backbone.Detour/blob/master/docs/extra_features.md#readme)

### Requirements

 - [Backbone.js](http://backbonejs.org/)
 - [underscore.js](http://underscorejs.org/)

--------------

Backbone.Detour was originally created by JD Isaacks for use in a project at [Emcien](https://github.com/emcien).
**Emcien is [hiring](http://emcien.com/about/careers/)**
