# Backbone.Detour Extra Features

### Required Params

You can set a parameter as **required** by passing it to *required* instead of *optional*:

```javascript
routeOptions: function() {
  this.required('owner');
}
```

Now if any params are set, but *owner* is not, then the object passed to `handleRoute` will be empty

### Default Values

```javascript
routeOptions: function() {
  this.optional('type', {default: 'manager'});
}
```

Now anytime *type* is not passed as a parameter to the route, the object passed to `handleRoute` will have a *type* property set to *manager*.

### Tokens

In **Backbone.Detour** all parameters are required to have a value. If you want to have a param without a value then list it as a token:

```javascript
routeOptions: function() {
  this.tokens('debug','someOtherToken');
}
```

Now any tokens that you are expecting, if set in the route will be listed as a second argument to `handleRoute`:

```javascript
handleRoute: function(args, toks) {
  if(toks.indexOf('debug') >= 0) {
    // do something
  }
}
```

### Arrays

You can tell **Backbone.Detour** to treat a param as an array:

```javascript
routeOptions: function() {
  this.optional('users', {type: 'array'});
}
```
Then when you update it, you pass an array of strings instead of just a single string:

```javascript
router.updateRoute({users: ['jim', 'steve']});
```
Then the values passed to `handleRoute` will also be an array:

```javascript
handleRoute: function(args) {
  console.log(args.users); // ['jim', 'steve']
}
```

You can also specify that you want new values to be automatically appended instead of replacing the array:

```javascript
routeOptions: function() {
  this.optional('users', {type: 'array', append: true});
}
```

You can then specify a limit of how many values to store when appending:

```javascript
routeOptions: function() {
  this.optional('users', {type: 'array', append: true, appendLimit: 2});
}
```

You can also specify that you want duplicated values to be cleared when appending:

```javascript
routeOptions: function() {
  this.optional('users', {type: 'array', append: true, unique: true});
}
```

And finally, you can specify your own comparator for uniqueness: 

```javascript
routeOptions: function() {
  this.optional('users', {type: 'array', append: true, unique: true, comparator: function(a,b){
    return a.substr(5) === b.substr(5);
  }});
}
```