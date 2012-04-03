App.NewContactView = Ember.View.extend
  tagName:      'form'
  templateName: 'ember/templates/contacts/edit'

  init: ->
    this._super()
    this.set "contact", App.Contact.create()

  didInsertElement: ->
    this._super()
    this.$('input:first').focus()

  cancelForm: ->
    this.get("parentView").hideNew()

  submit: (event) ->
    self = this
    contact = this.get "contact"

    event.preventDefault()

    contact.saveResource()
      .fail (e) ->
        App.displayError e
      .done ->
        App.contactsController.pushObject contact
        self.get("parentView").hideNew()

