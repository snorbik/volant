Volant.ApplyFormActionPickerController = Ember.ObjectController.extend Volant.AjaxToStoreMixin,
  actions:
    changeState: ->
      action = @get('action_name')
      form = @get('apply_form')
      url = "/apply_forms/#{form.get('id')}/#{action}"
      @ajax_to_store(url).then ((payload) =>
        @flash_info 'State changed'), (err) =>
        console.error err
        @flash_error 'Failed.'
      @send 'closeModal'

    openMessage: ->
      action_name = @get('action_name')
      apply_form = @get('apply_form')

      @store.find('user',@get('current_user.content.id')).then (user) =>
        apply_form.get('current_workcamp').then (workcamp) =>
          message = @store.createRecord 'message', {
            action: action_name
            apply_form: apply_form
            user: user
          }

          if action_name == 'ask'
            xml = @store.createRecord 'attachment', { type: 'VefAttachment',applyForm: apply_form }
            pdf = @store.createRecord 'attachment', { type: 'VefPdfAttachment',applyForm: apply_form }
            html = @store.createRecord 'attachment', { type: 'VefHtmlAttachment',applyForm: apply_form }                        

            attachments = message.get('attachments')
            attachments.pushObject(vef)
            attachments.pushObject(html)
            attachments.pushObject(pdf)

          @transitionToRoute('message',message)

      @send 'closeModal'
