require "bundler/capistrano"
require 'static_docs/capistrano'

require 'capistrano/ext/multistage'
set :stages, %w(v32 v40)
set :default_stage, "v40"

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/monit"

server "78.47.229.178", :web, :app, :db, primary: true

set :user, 'admin'
set(:deploy_to){ "/home/#{user}/apps/#{application}" }
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:morsbox/rusrails.git"

set :bundle_cmd, '/home/admin/.rbenv/shims/bundle'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  desc "Seed the database with the required data"
  task :seed do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")

    run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} db:seed"
  end

  after "deploy:seed", "static_docs:import"
end

after "deploy", "deploy:cleanup"
