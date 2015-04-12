Volant.MessageRoute = Volant.BaseRoute.extend
  templateName: 'message'
  controllerName: 'message'
  toolbar: 'message/toolbar'

  title: (model) -> "#{model.get('subject')}"

  afterSave: (record) ->
    @flash_info('Message saved.')

    if form = record.get('apply_form')
      @transitionTo 'apply_form',form.get('id')
    else
      @transitionTo 'message',record.get('id')

  model: (params) ->
    if params.message_id != 'null'
      @store.find('message', params.message_id)
    else
      @transitionTo 'messages'

  setupController: (controller,message) ->
    @store.find('email_template').then (templates) =>
      message.get('apply_form').then (apply_form) =>
        tmpl = templates.findBy('action',@_templateNameFor(message,apply_form))
        @controllerFor('email_templates').set('content',templates)
        controller.set('selectedTemplate',tmpl)

        if message.get('isNew') && tmpl
          @applyTemplate(tmpl,message,apply_form)

    @_super(controller,message)

  applyTemplate: (tmpl,message,apply_form) ->
    error = (e) =>
      console.error e
      @flash_error e

    @_message_context(message,apply_form).then ((context) =>
      console.log 'Message context', context
      message.set 'subject', tmpl.eval_field('subject',context,error)
      message.set 'html_body', tmpl.eval_field('body',context,error)
      message.set 'from', tmpl.eval_field('from',context,error)
      message.set 'to', tmpl.eval_field('to',context,error)
      message.set 'cc', tmpl.eval_field('cc',context,error)
      message.set 'bcc', tmpl.eval_field('bcc',context,error)),error

  _templateNameFor: (message,form) ->
    action = message.get('action')
    resource = form || message.get('workcamp')    
    return action unless resource    

    type = resource.get('type')

    if type == 'outgoing'
      action
    else
      "#{type}/#{action}"            

  _message_context: (message,apply_form) ->
    if apply_form    
      apply_form.get('currentWorkcamp').then =>
        @_buildContext(message,apply_form,workcamp)
    else
      empty = (resolve,reject) -> resolve()
      new Ember.RSVP.Promise(empty).then =>
        @_buildContext(message,apply_form,message.get('workcamp'))
            

  _buildContext: (message,apply_form,workcamp) ->
      context = {}
      user = message.get('user')

      if user
        context.user = user.for_email()

      if apply_form
        context.application = apply_form.for_email()
        # legacy alias
        context.apply_form = context.application

        if volunteer = apply_form.get('volunteer')
          context.volunteer = volunteer.for_email()

      if workcamp
        context.workcamp = workcamp.for_email()
        # legacy alias
        context.wc = context.workcamp

        if org = workcamp.get('organization')
          context.organization = org.for_email()

      console.debug 'Message context:',context  
      context  


  actions:
    useTemplate: (tmpl) ->
      @currentModel.get('apply_form').then (apply_form) =>
        @applyTemplate(tmpl,@currentModel,apply_form)
      false

    sendMessage: ->
      @currentModel.save().then (msg) =>
        form = msg.get('apply_form')
        url = "/messages/#{msg.get('id')}/deliver"
        @ajax_to_store(url).then ((payload) =>
          @transitionTo('apply_form', form) if form
          @flash_info 'Message sent.'),
        =>
          @flash_error 'Send failed'
      false

    showUploadDialog: ->
      @render 'message/upload_attachment',outlet: 'modal',model: @currentModel, controller: 'message_upload_attachment'
      false

    destroyAttachment: (attachment) ->
      console.log 'Attachment destroyed.'
      attachment.destroyRecord()
      false
