# Journals

A journal system for small schools.

## Architecture

This is a single page application where the backend APIs are served by Ruby on Rails (3.2) and the front end uses AngularJS (1.1.5). Postgresql is the database used. SASS is used as a precompiler for CSS and HAML for HTML. The app has been tested on Ruby 1.9.3-p551.

AngularJS tests are run using jasmine and karma. Backend unit tests use RSpec and end-to-end tests use Cucumber along with Capybara and RSpec.

The [cancan](https://github.com/ryanb/cancan) gem is used for roles and authorisation, so you'll find helper methods from this gem in backend rails controller. For a list of all ruby gems used, looked at the `Gemfile`.

On the front end, a model is defined in `model.js` along with some helpers for associations between models in `modelAssociations.js`. These are used as the base models for each resource in the app.

## Important files and directories
- `app/assets/javascripts/angular`: Front end JS files
- `app/assets/stylesheets`: SASS files
- `app/assets/templates`: Front end HAML templates
- `app/controllers`: Backend rails controllers
- `app/helpers`: Helpers for backend templates
- `app/mailers`: Controllers for backend mailers
- `app/models`: Backend rails models
- `app/views`: JSON definitions for each route in the backend API
- `config/sensitive.yml`: Contains authentication info. This does not exist in the repo and should be copied from `config/sensitive.yml.eg` and filled in.
- `config/settings.yml`: Contains non-sensitive settings.

## Setup
Ensure that the following requirements are installed on your system:
- Ruby 1.9.3 (You can try [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv) for version management)
- Postgresql
- ImageMagick
- openssl

If you are going to run integration tests, you will need the following dependencies. *These is not required for a production setup*.
- NodeJS and NPM
- PhantomJS

Clone the repository and run `bundle install`.

If you get the error `-bash: bundle: command not found`, run  `gem install bundler` first. If it still does not work, restart your terminal window in case your `PATH` was not updated.

Set up your postgresql database(s). Note that if you set your `db_name` to `sample_school`, the dev, test and production databases will automatically be assumed to be `sample_school_development`, `sample_school_test`, and `sample_school_production`. If you intend to run tests, ensure the user for the test database is a `SUPERUSER` or can create databases. *This should not be the case in production.*

Ensure that the values in `config/settings.yml` are correct. Copy `config/sensitive.yml.eg` to `config/sensitive.yml` and fill it up with authentication information.

Run `bundle exec rake db:schema:load` to initialise the database tables.

## Run tests
Run `npm install` to install test dependencies.

Run `bundle exec rake db:test:prepare` to prepare the test database. 

To run backend unit tests, run `bundle exec rspec spec`.

To run frontend unit tests, run `node_modules/.bin/karma start --single-run`.

To run integration tests, run `bundle exec rake cucumber`. Integration tests cover the application widely, but are not a 100% stable - if you see a few failures, rerun the tests to see if they are due to test instability.

## Run in development mode
To create a initial user, run `bundle exec rake db:seed`. Log in with `user@demo.com` and the password `demo`.

Run `bundle exec rails s` and view the site at http://localhost:3000.

## Deploy to production

TODO - capistrano instructions