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
- `config/deploy.rb`: Deployment config and tasks.

## Setup
Ensure that the following requirements are installed on your system:
- Ruby 1.9.3 (You can try [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv) for version management)
- Postgresql
- ImageMagick
- openssl

If you are going to run integration tests, you will need the following dependencies. **These is not required for a production setup**.
- NodeJS and NPM
- PhantomJS

Clone the repository and run `bundle install`.

If you get the error `-bash: bundle: command not found`, run  `gem install bundler` first. If it still does not work, restart your terminal window in case your `PATH` was not updated.

Set up your postgresql database(s). Note that if you set your `db_name` to `sample_school`, the dev, test and production databases will automatically be assumed to be `sample_school_development`, `sample_school_test`, and `sample_school_production`. If you intend to run tests, ensure the user for the test database is a `SUPERUSER` or can create databases. **This should not be the case in production.**

Ensure that the values in `config/settings.yml` are correct. Copy `config/sensitive.yml.eg` to `config/sensitive.yml` and fill it up with authentication information. **Note that the top level key must be the same as the app_name in `config/settings.yml`.**

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

## Connecting to a remote host
Capistrano 2 is used both for deployment to production and for maintenance and migration. Before you can use it, you will need to be able to log in to your remote host using an SSH key for authentication. See this for more information: http://capistranorb.com/documentation/getting-started/authentication-and-authorisation/. For AWS EC2, a `.pem` key file can be used to SSH in.

Make sure `config/settings.yml` and `config/sensitive.yml` have been properly configured. The `host` and `user` parameters in `config/settings.yml` are used to SSH into the remote host. If a `.pem` key file is needed to log into the host, you should specify the path to the file in `config/sensitive.yml` as `ssh_key_path`.

Look through `config/deploy.rb` for the capistrano setup. Comment out the RVM section if you're not using RVM on the remote host. Running `cap -T` will show you a list of all capistrano tasks - default and custom. Please note that you will have to search for archived documentation for Capistrano 2, not the newer capistrano 3 for more information.

## Deploy to production
The simplest way to deploy the application is using Phusion Passenger. Detailed setup instructions for passenger are here: https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/

To deploy the application, you can either use the repository directly or use capistrano.

Instructions for capistrano:

- Run `cap deploy:setup`
- Fill `config/sensitive.yml` with authentication information for the remote host and run `cap sensitive_data:setup` to copy it to the remote server
- Restore `config/sensitive.yml` to the development information
- Make sure you can access github with ssh key authentication. If you run `ssh -T git@github.com`, you should see a welcome message. For more info, see: https://help.github.com/articles/generating-an-ssh-key/
- Run `cap deploy:cold`. This will fail on the `db:migrate` step
- Run `cap db:schema_load`
- Run `cap deploy`

For a code update after this initial deployment, just run `cap deploy`.

## Maintenance and migration
To import the database from the production server to the development setup, run `cap db:import_from_remote`. To export it to the production server, run `cap db:export_to_remote`. Be careful with this as it will overwrite current data. You can use this to migrate data from one server to another or view it in development.

To run a ruby console on the remote application, ssh into the host, cd into the current deploy directory and run `RAILS_ENV=production bundle exec rails c`.

Make sure the email SMTP settings are setup in `config/settings.yml` and `config/sensitive.yml` for emails to work. An external SMTP service such as AWS SES should be used.

For automated backups, set up an AWS S3 bucket for the backups and create an IAM user with full access to that bucket. Enter the bucket name in `config/settings.yml` as `s3_backups_bucket`. Make sure `aws_domain` is set to the correct endpoint for the region of your S3 bucket. **For authentication for the database backup, you will need to create a .pgpass file in the home directory of the remote machine.** Follow these instructions to do so: https://www.postgresql.org/docs/current/static/libpq-pgpass.html.

To manually backup the remote database and uploads, run `cap backups:create` from your local setup.