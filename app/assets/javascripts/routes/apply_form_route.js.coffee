Volant.ApplyFormRoute = Volant.BaseRoute.extend({

  model: (params) ->
    @store.find('apply_form', params.apply_form_id)

  title: (model) -> "#{model.get('name')}"

  renderTemplate: ->
    @_super()
    @render('apply_form/page_up',into: 'application', outlet: 'page_up')
    @render('quick_save',into: 'application', outlet: 'item_controls')

  actions:
    accept: ->
      msg = @store.createRecord('message')
      @controllerFor('message').set('model', msg)
      @render 'message', into: 'application',outlet: 'modal'
      false

#  setupController: (controller, model) ->
#    @controllerFor('workcamps').set('current_item', model);
#    @_super(controller, model);

#  deactivate: ->
#    @controllerFor('workcamps').set('current_item', null);
})
