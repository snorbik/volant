Volant.HiddenSaveButtonComponent = Ember.Component.extend
  tagName: 'button'
  type: 'submit'
  style: 'display:hidden'
  attributeBindings: ['type','style']

# Volant.SaveFormComponent = Ember.Component.extend
#   role: 'form'
#   attributeBindings: ['role']
#   submitAction: 'save'
  
#   submit: ->
#     @sendAction 'submitAction'
