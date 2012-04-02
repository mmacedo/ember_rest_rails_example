App.Contact = Ember.Resource.extend
  resourceUrl:        '/contacts'
  resourceName:       'contact'
  resourceProperties: ['first_name', 'last_name']

  validate: ->
    unless this.get('first_name') and
           this.get('last_name')
      'Contacts require a first and a last name.'

  fullName: (->
    "#{this.get 'first_name'} #{this.get 'last_name'}"
    ).property 'first_name', 'last_name'
