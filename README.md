= Sample application with Rails, Ember and Ember-REST

This is a step by step to generate this sample application.

== Version

If the versions are not exact as below, one or more steps may be different. If the versions below differ too highly, this tutorial may not be useful for you.

Running `ruby -v` gives me `ruby 1.9.3p125` plus some garbage.
Running `rails -v` gives me `Rails 3.2.2`.
The version of my Ember.js is "0.9.4".

== Create the application

Execute the following lines in your shell (Windows users: a bash (a popular specie of shell) comes with Rails and Git) to create an empty application:

    rails new ember_rest_rails_example -T
    cd ember_rest_rails_example
    rm -rf doc README.rdoc
    touch README.md

Edit the application Gemfile and add the following lines after the
`gem 'jquery-rails'`:

    gem 'ember-rails'
    gem 'ember-rest-rails'

Run `bundle` to install the gems.

Run the following command to create the directory structure:

    mkdir -p
app/assets/javascripts/ember/{controllers,helpers,models,templates,views}

Modify `app/assets/javascripts/ember/app.js.coffee` to look like this:

    //= require_self
    //= require_tree controllers
    //= require_tree helpers
    //= require_tree models
    //= require_tree templates
    //= require_tree views
    
    window.App = Ember.Application.create()

Edit `app/assets/javascripts/application.js` and add the following lines
before `require_tree .`:

    //= require ember
    //= require ember-rest
    //= require ember/app

You created the basic structure to start coding your application. Next
let's start adding models and controllers.

== Create models and controllers

Run the following in the shell to scaffold models and controllers:

    rails generate model Contact firt_name:string last_name:string
    rails generate scaffold_controller Contacts
    rm -rf app/views/contacts
    rake db:migrate

Modify `app/models/contact.rb` and add these validations:

    validates :first_name, :presence => true
    validates :last_name, :presence => true

Create `app/assets/javascripts/ember/models/contact.js.coffee` with the
following content:

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

Create `app/assets/javascripts/ember/controllers/contacts.js.coffee` with the following content:

    App.contactsController = Ember.ResourceController.create
      resourceType: App.Contact

That is all for models and controllers, next we start to create views.
