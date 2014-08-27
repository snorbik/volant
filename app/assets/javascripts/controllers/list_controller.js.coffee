Volant.ListController = Ember.ArrayController.extend({

  current_year: 2014
  current_page: 1
  filter_is_visible: false
  filter: null

  pagination: (->
    if @get('model.isLoaded')
      modelType = @get('model.type')
      @get('store').typeMapFor(modelType).metadata.pagination
  ).property('model.isLoaded')

  previous_page_exists: (->
    @get('current_page') > 1
  ).property('current_page')

  next_page_exists: (->
    @get('current_page') < @get('pagination.total_pages')
  ).property('pagination','current_page')

})