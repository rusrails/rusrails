require "bundler/capistrano"
require 'thinking_sphinx/deploy/capistrano'

server "78.47.229.178", :web, :app, :db, primary: true

set :application, "rusrails_v40"
set :user, 'admin'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:morsbox/rusrails.git"
set :branch, "master"

set :bundle_cmd, '/home/admin/.rbenv/shims/bundle'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/settings.local.yml"), "#{shared_path}/config/settings.yml"
    puts "Now edit the config files in #{shared_path}."
  end

  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings/production.yml"
  end

  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  desc "Seed the database with the required data"
  task :seed do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")

    run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} db:seed"
    run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} pages:import"
    run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} pages:cleanup"
  end

  after "deploy:seed", "thinking_sphinx:rebuild"
end

before "deploy", "deploy:check_revision"
after "deploy", "thinking_sphinx:rebuild"
after "deploy", "deploy:cleanup"
