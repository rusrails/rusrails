require 'thinking_sphinx/capistrano'

set :application, "rusrails_v32"
set :branch, "v3.2"

set :subdomains, %w(v32.rusrails.ru)

set :unicorn_workers, 1

after "deploy:seed", "thinking_sphinx:rebuild"
