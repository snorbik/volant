Volant.Message = DS.Model.extend
  user: DS.belongsTo 'user'
  email_template: DS.belongsTo 'email_template',async: false
  apply_form: DS.belongsTo 'apply_form',async: false

  to: DS.attr 'string'
  cc: DS.attr 'string'
  bcc: DS.attr 'string'
  from: DS.attr 'string'
  subject: DS.attr 'string'
  body: DS.attr 'string'
  html_body: DS.attr 'string'
  sent_at: DS.attr 'date'
  action: DS.attr 'string'

  # for the collision with {{action}} helper in Handlebars templates
  action_name: Ember.computed.alias('action')
  delivered: Ember.computed.alias('sent_at')

  template_changed: (->
    context = {
     user: if @get('user')? then @get('user').for_email() else null
     volunteer: if @get('apply_form.volunteer')? then  @get('apply_form.volunteer').for_email() else null
     wc: if @get('apply_form.current_workcamp')? then @get('apply_form.current_workcamp').for_email() else null
    }

    if tmpl = @get('email_template')
      @set 'subject',tmpl.eval_subject(context)
      @set 'body',tmpl.eval_body(context)
  ).observes('email_template')
