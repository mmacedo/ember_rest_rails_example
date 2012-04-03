App.EditContactView = Ember.View.extend
  tagName:      'form'
  templateName: 'ember/templates/contacts/edit'

  init: ->
    # create a new contact that's a duplicate of the contact in the parentView;
    # changes made to the duplicate won't be applied to the original unless
    # everything goes well in submitForm()
    editableContact = App.Contact.create this.get('parentView').get('contact')
    this.set "contact", editableContact
    this._super()

  didInsertElement: ->
    this._super()
    this.$('input:first').focus()

  cancelForm: ->
    this.get("parentView").hideEdit()

  submit: (event) ->
    self = this
    contact = this.get "contact"

    event.preventDefault()

    contact.saveResource()
      .fail (e) ->
        App.displayError e
      .done ->
        parentView = self.get "parentView"
        parentView.get("contact").duplicateProperties(contact)
        parentView.hideEdit()
