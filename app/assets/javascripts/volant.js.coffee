#= require jquery
#= require handlebars
#= require ember
#= require ember-data
#= require images


#= require moment
## require moment/czech.js
## require moment/english.js


#= require modernizr
#= jquery-ui/datepicker
#= date-polyfill.min

#= require_self
#= require ./store
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./components
#= require_tree ./templates
#= require_tree ./routes
#= require ./router



# for more details see: http://emberjs.com/guides/application/
window.Volant = Ember.Application.create()