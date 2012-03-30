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

    //= require_tree controllers
    //= require_tree helpers
    //= require_tree models
    //= require_tree templates
    //= require_tree views
    //= require_tree .
    
    window.App = Ember.Application.create()

Edit `app/assets/javascripts/application.js` and add the following lines
before `require_tree .`:

    //= require ember
    //= require ember-rest
    //= require ember/app

You created the basic structure to start coding your application. Next
let's start adding models and controllers.
