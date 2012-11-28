require 'rubygems'
require 'spork'
 
Spork.prefork do
  require 'cucumber/rails'

  Capybara.default_selector = :css

  Before('@javascript') do
    require 'headless'
    headless = Headless.new
    headless.start
  end

end
 
Spork.each_run do
  ActionController::Base.allow_rescue = false
  DatabaseCleaner.strategy = :transaction
  Cucumber::Rails::Database.javascript_strategy = :truncation
end
