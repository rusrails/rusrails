require 'cucumber/rails'

require 'capybara'
require 'capybara/rails'
require 'capybara/cucumber'
Capybara.default_selector = :css

ActionController::Base.allow_rescue = false

Cucumber::Rails::World.use_transactional_fixtures = false

require 'cucumber/thinking_sphinx/external_world'
Cucumber::ThinkingSphinx::ExternalWorld.new
DatabaseCleaner.strategy = :truncation

#Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#  DatabaseCleaner.strategy = :truncation
#end
#
#Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#  DatabaseCleaner.strategy = :transaction
#end

require 'webrat'
require 'webrat/core/matchers'
Webrat.configure do |config|
  config.mode = :rack
  config.open_error_files = false
end
World(Webrat::Methods)
World(Webrat::Matchers)
