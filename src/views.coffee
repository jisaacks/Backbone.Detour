class @Views
  class @Base extends Backbone.View
    template: _.template(
      '''
      <h2><%= title %></h2>
      <p><%= message %></p>
      <div class="nav">
        <% if(prev) { %>
        <a class="prev" href="<%= prev %>">Prev</a>
        <% } if(next) { %>
        <a class="next" href="<%= next %>">Next</a>
        <% } %>
      </div>
      '''
    )
    render: (prev) ->
      console.log prev
      @$el.html @template
        title:   @title
        message: @message
        next:    @next
        prev:    prev
      @

  class @Intro extends Views.Base
    title: "Introduction"
    message: "Backbone.detour lets you use your router as a parameter store."
    next: '#section/usage'

  class @Usage extends Views.Base
    title: "Usage"
    message: "First extend Backbone.Router."