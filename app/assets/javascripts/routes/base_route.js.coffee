Volant.BaseRoute = Ember.Route.extend({
  afterModel: (model,transition) ->
    if title = @get('title')
      $(document).attr('title', "#{title.call(this,model)} - Volant")
    else
      'Volant'

  setupController: (controller,model) ->
    @setupPagination(controller,model)
    @_super(controller,model)

  actions:
    toggle_starred: (model) ->
      data = { star: { id: model.get('id'), model: model.constructor.typeKey.decamelize(), value: !model.get('starred') }}
      @ajax_to_store('/stars',data).then (payload) =>
        console.log 'Starred'


    save: ->
      model = @modelFor(@routeName)
      model.get('errors').clear()
      model.save().then ( (wc) =>
        @go_to_plural_route(model)
        @flash_info 'Saved.'
       ), ( (e) =>
         @flash_error 'Failed.'
       )
      false

    remove: ->
      model =  @modelFor(@routeName)
      model.destroyRecord().then =>
        @flash_info 'Saved.'
        @go_to_plural_route(model)


    rollback: ->
      model = @modelFor(@routeName)
      model.get('errors').clear()
      model.rollback()
      @go_to_plural_route(model)
      false

  # ----- Normal Methods ------

  go_to_plural_route: (model) ->
    next_route = model.constructor.typeKey.decamelize().pluralize()
    @transitionTo next_route if @routeName != next_route

  setupPagination: (controller,model) ->
    modelType = model.get('type') if model.get?
    if hash = @store.typeMapFor(modelType).metadata.pagination
      controller.set('controllers.pagination.model', Ember.Object.create(hash))

  flash_info: (msg) ->
    @controllerFor('application').set('flash', {type: 'success', message: msg })

  flash_error: (msg) ->
    @controllerFor('application').set('flash', {type: 'error', message: msg })


  ajax_to_store: (url,data = {}) ->
    new Promise (resolve, reject) =>
      csrf_token = $('meta[name="csrf-token"]').attr('content')
      csrf_param = $('meta[name="csrf-param"]').attr('content')
      data.authenticity_token = csrf_token

      try
        $.post url, data, (response) =>
          @store.pushPayload(response)
          resolve(response)
      catch e
        reject(e)

})
