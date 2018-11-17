require "bundler/capistrano"
require 'static_docs/capistrano'

require 'capistrano/ext/multistage'
set :stages, %w(production)
set :default_stage, "production"

load "config/recipes/base"
load "config/recipes/ruby"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/monit"
load "config/recipes/yarn"

server "95.216.150.195", :web, :app, :db, primary: true

# adduser admin
# usermod -aG sudo admin
# ssh admin@95.216.150.195 mkdir -p .ssh
# cat ~/.ssh/id_rsa.pub | ssh admin@95.216.150.195 'cat >> .ssh/authorized_keys'
set :user, 'admin'
set(:deploy_to) { "/home/#{user}/apps/#{application}" }
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:morsbox/rusrails.git"


default_run_options[:pty] = true
default_run_options[:shell] = '/bin/bash --login'
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
