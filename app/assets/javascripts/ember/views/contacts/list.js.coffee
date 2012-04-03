App.ListContactsView = Ember.View.extend
  templateName:    'ember/templates/contacts/list'
  contactsBinding: 'App.contactsController'

  showNew: ->
    this.set 'isNewVisible', true

  hideNew: ->
    this.set 'isNewVisible', false

  refreshListing: ->
    App.contactsController.findAll()
