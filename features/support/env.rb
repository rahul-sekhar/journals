require 'rubygems'
require 'spork'

Spork.prefork do
  ENV['CUCUMBER'] ||= 'true'

  require 'cucumber/rails'

  require 'email_spec'
  require 'email_spec/cucumber'

  require 'capybara/poltergeist'

  Capybara.default_selector = :css
  Capybara.default_driver = :poltergeist

  Delayed::Worker.delay_jobs = false
end

Spork.each_run do
  ActionController::Base.allow_rescue = false
  DatabaseCleaner.strategy = :truncation
  # Cucumber::Rails::Database.javascript_strategy = :truncation
  load "#{Rails.root}/config/routes.rb"
end
