source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem 'rake', '0.8.7'         # remove this line when rails 3.1
gem 'mysql2', '= 0.2.7'     # version needed for rails 3.0
gem 'thinking-sphinx'
gem 'devise'
gem 'nokogiri'
gem 'haml'
gem 'sass'

gem 'jquery-rails'
gem 'capistrano'

group :development, :test do
  gem "rspec-rails"
  gem "cucumber-rails"
  gem 'webrat'
  gem 'capybara', "= 1.0.0.beta1"   # remove this line when rails 3.1
  # until bug with :to_ary not fixed:
  gem "rspec-mocks", :git => "git://github.com/rspec/rspec-mocks.git"
end

group :test do
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end