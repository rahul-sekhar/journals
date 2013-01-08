require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rspec'
  require "cancan/matchers"
  require "#{Rails.root}/spec/support/capybara_extensions.rb"
  require 'email_spec'

  RSpec.configure do |config|
    config.use_transactional_fixtures = true
    config.infer_base_class_for_anonymous_controllers = false

    config.order = "random"

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.filter_run_excluding :skip => true
    config.run_all_when_everything_filtered = true

    config.include FactoryGirl::Syntax::Methods

    # Load the view helper
    config.include RSpec::CapybaraExtensions, type: :view
  end

  # Pre-loading for performance:
  require 'rspec/mocks'
  require 'rspec/expectations'
  require 'rspec/matchers'
  require 'rspec/core'
end

Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  # Randomise RSpec seed
  RSpec.configuration.seed = srand && srand % 0xFFFF
  
  FactoryGirl.reload
  
  # Load support files
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end
