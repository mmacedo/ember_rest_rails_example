App.ShowContactView = Ember.View.extend
  templateName: 'ember/templates/contacts/show'
  classNames:   ['show-contact']
  tagName:      'tr'

  doubleClick: ->
    this.showEdit()

  showEdit: ->
    this.set 'isEditing', true

  hideEdit: ->
    this.set 'isEditing', false

  destroyRecord: ->
    contact = this.get "contact"

    contact.destroyResource()
      .fail (e) ->
        App.displayError e
      .done ->
        App.contactsController.removeObject contact
