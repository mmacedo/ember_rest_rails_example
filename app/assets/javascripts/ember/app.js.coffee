#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates

window.App = Ember.Application.create()

window.App.displayError = (e) ->
  if typeof e is "string"
    alert e
  else if e?.responseText?
    alert e.responseText
  else
    alert "An unexpected error occured."
