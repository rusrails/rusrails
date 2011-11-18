source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem 'rake', '0.8.7'         # remove this line when rails 3.1
gem 'rack', '1.2.3' # quick fix for locum
gem 'mysql2', '= 0.2.7'     # version needed for rails 3.0
gem 'thinking-sphinx'
gem 'devise', '= 1.4.9'     # Something broken in 1.5.0, wait for next
gem "oa-oauth", :require => "omniauth/oauth"

gem 'nokogiri'
gem 'haml'
gem 'sass'
gem 'RedCloth'
gem 'rails_config'

gem 'jquery-rails'
gem 'capistrano'

group :development, :test do
  gem "rspec-rails"
  gem "cucumber-rails"
  gem 'webrat'
  gem 'capybara', "= 1.0.0.beta1"   # remove this line when rails 3.1
end

group :test do
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end
