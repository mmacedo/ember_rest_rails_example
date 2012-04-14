# Sample application with Rails, Ember and Ember-REST

This is a step by step to generate this sample application. It uses CoffeeScript, SASS and Haml. Except for that and the use of this gem, it is basically a similar example:

https://github.com/dgeb/ember_rest_example

## Version

If the versions are not exact as below, one or more steps may be different. If the versions below differ too highly, this tutorial may not be useful for you.

Running `ruby -v` gives me `ruby 1.9.3p125` plus some garbage.
Running `rails -v` gives me `Rails 3.2.2`.
The version of my Ember.js is "0.9.4".

## Create the application

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

## Create models and controllers

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

## Create views

### Setup Haml (optional)

Modify Gemfile and add the following lines to the `:asset` group:

    gem 'haml-rails'
    gem 'coffee-filter'

Now run `bundle` and translate your already generated files. The deault Rails 3 layout at `app/views/layouts/application.html.erb` would become
`app/views/layouts/application.html.haml` and look like this:

    !!!
    %html
      %head
        %title EmberRestRailsExample
        = stylesheet_link_tag    "application", :media => "all"
        = javascript_include_tag "application"
        = csrf_meta_tags
      %body
        = yield

### Create Rails views

You actually will need just one.

Create `app/views/contacts/index.html.haml` with the following content:

    %h1 Contacts

    %script{:type => "text/x-handlebars"}
      :plain
        {{ view App.ListContactsView }}

    :coffeescript
      $ ->
        App.contactsController.loadAll #{ @contacts.to_json.html_safe }

The first creates an instance of the view that list contacts (not created yet) and the second loads the controller with data without making a second round-trip for the first load.

### Create Ember views (logical view)

These are the actual views, so we will create one for each action under `app/asssets/javascripts/ember/views/contacts`.

new.js.coffee

    App.NewContactView = Ember.View.extend
      tagName:      'form'
      templateName: 'app/templates/contacts/edit'

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

edit.js.coffee

    App.EditContactView = Ember.View.extend
      tagName:      'form'
      templateName: 'app/templates/contacts/edit'

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

show.js.coffee

    App.ShowContactView = Ember.View.extend
      templateName: 'app/templates/contacts/show'
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

list.js.coffee

    App.ListContactsView = Ember.View.extend
      templateName:    'app/templates/contacts/list'
      contactsBinding: 'App.contactsController'

      showNew: ->
        this.set 'isNewVisible', true

      hideNew: ->
        this.set 'isNewVisible', false

      refreshListing: ->
        App.contactsController.findAll()

Finally, let's see what it prints... no, wait: it won't print
anything because we just made our logical views, now we need the view view or as it is called: the template.

### Create Ember templates (view view)

These are the views of the logical views, we referenced three different templates in the views, so now we need to create them under `app/assets/javascripts/ember/templates/contacts`.

Important note: it is pure html with handlebars, no haml.
Other important notice: it looks like html, but they will be actually compiled to javascript that will then generate html in the client.

edit.handlebars

    {{#with contact}}
      {{view Ember.TextField valueBinding="first_name" placeholder="First name"}}
      {{view Ember.TextField valueBinding="last_name"  placeholder="Last name"}}
      <button type="submit">
        {{#if id}}Update{{else}}Create{{/if}}
      </button>
    {{/with}}
    <a href="#" {{action "cancelForm"}}>Cancel</a>

show.handlebars

    <td>{{contact.id}}</td>
    <td class="data">
      {{#if isEditing}}
        {{view App.EditContactView}}
      {{else}}
        {{contact.fullName}}
      {{/if}}
      <div class="commands">
        {{#unless isEditing}}
          <a href="#" {{action "showEdit"}}>Edit</a>
          <a href="#" {{action "destroyRecord"}}>Remove</a>
        {{/unless}}
      </div>
    </td>

list.handlebars

    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
        </tr>
      </thead>
      <tbody>
      {{#each contacts}}
        {{view App.ShowContactView contactBinding="this"}}
      {{/each}}
      {{#if isNewVisible}}
        <tr>
          <td>*</td>
          <td>
            {{view App.NewContactView}}
          </td>
        </tr>
      {{/if}}
      </tbody>
    </table>
    <div class="commands">
      <a href="#" {{action "showNew"}}>New Contact</a>
      <a href="#" {{action "refreshListing"}}>Refresh Listing</a>
    </div>

## Before we run it

The app was built, but we would better make some adjust that is specific
to each app, but will be needed.

We referenced a function to handle the errors and we didn't declare it.
Modify `app/assets/javascripts/ember/app.js.coffee` and add this:

    window.App.displayError = (e) ->
      if typeof e is "string"
        alert e
      else if e?.responseText?
        alert e.responseText
      else
        alert "An unexpected error occured."

Create `app/assets/stylesheets/base.css.scss` with the following
content:

    body {
      background-color: #fff;
      color: #333;
      font-family: verdana, arial, helvetica, sans-serif;
      font-size: 13px;
      line-height: 18px;
    }

    p, ol, ul, td {
      font-family: verdana, arial, helvetica, sans-serif;
      font-size: 13px;
      line-height: 18px;
    }

    pre {
      background-color: #eee;
      padding: 10px;
      font-size: 11px;
    }

    a {
      color: #000;
      &:visited {
        color: #666;
      }
      &:hover {
        color: #fff;
        background-color: #000;
      }
    }

    div {
      &.field, &.actions {
        margin-bottom: 10px;
      }
    }

    #notice {
      color: green;
    }

    .field_with_errors {
      padding: 2px;
      background-color: red;
      display: table;
    }

    #error_explanation {
      width: 450px;
      border: 2px solid red;
      padding: 7px;
      padding-bottom: 0;
      margin-bottom: 20px;
      background-color: #f0f0f0;
      h2 {
        text-align: left;
        font-weight: bold;
        padding: 5px 5px 5px 15px;
        font-size: 12px;
        margin: -7px;
        margin-bottom: 0px;
        background-color: #c00;
        color: #fff; 
      }
      ul li {
        font-size: 12px;
        list-style: square;
      }
    }

    .commands {
      a {
        margin-right: 5px;
      }
    }

    table {
      margin-bottom: 15px;

      th, td {
        text-align: left;
        padding: 2px 8px 2px 0;
      }

      input[type='text'] {
        width: 80px;
      }

      td.data {
        width: 300px;

        div.commands {
          float: right;
          margin-right: 20px;
        }
      }
    }

## The End

Now run it with `rails server`.
