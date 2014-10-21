Volant.ApplyFormsRoute = Volant.BaseRoute.extend({
  model: (params) ->
    @store.find('apply_form', { p: params.page, year: params.year, q: params.query })

  title: -> "Applications"

  renderTemplate: ->
    @render('apply_forms')

  actions:
    search: ->
      @refresh()
      false

    refresh: ->
      @refresh()
      false
})
