require "bundler/capistrano"
require 'thinking_sphinx/deploy/capistrano'
load 'deploy/assets'

set :application, "rusrails"

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :repository, "git@github.com:morsbox/rusrails.git"  # Your clone URL
# set :branch, "production"
set :scm, "git"
set :deploy_via, :remote_cache

dpath = "/home/hosting_mik-die/projects/rusrails"

set :user, "hosting_mik-die"

set :use_sudo, false
set :deploy_to, dpath
set :bundle_cmd, 'rvm use 1.9.3-p125 do bundle'
set :bundle_flags, "--deployment"

role :web, "hydrogen.locum.ru"
role :app, "hydrogen.locum.ru"
role :db,  "hydrogen.locum.ru", :primary => true

set :unicorn_conf, "/etc/unicorn/rusrails.mik-die.rb"
set :unicorn_pid, "/var/run/unicorn/rusrails.mik-die.pid"
set :unicorn_start_cmd, "(cd #{dpath}/current; rvm use 1.9.3-p125 do bundle exec unicorn_rails -Dc #{unicorn_conf})"

# - for unicorn - #
namespace :deploy do
  task :copy_configuration do
    run "cp #{shared_path}/config/database.yml #{current_release}/config/database.yml"
    run "cp #{shared_path}/config/production.yml #{current_release}/config/settings/production.yml"
  end
  before "deploy:assets:precompile", "deploy:copy_configuration"

  task :migrate, :roles => :db do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest then current_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
    end

    puts "#{migrate_target} => #{directory}"
    run "cd #{directory}; #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:migrate"
  end

  after "deploy:symlink", "deploy:migrate"

  desc "Seed the database with the required data"
  task :seed do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")

    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:seed"
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} pages:import"
  end
  # after "deploy:migrate", "deploy:seed"

  desc "Start application"
  task :start, :roles => :app do
    run unicorn_start_cmd
  end

  desc "Stop application"
  task :stop, :roles => :app do
    run "[ -f #{unicorn_pid} ] && kill -QUIT `cat #{unicorn_pid}`"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "[ -f #{unicorn_pid} ] && kill -USR2 `cat #{unicorn_pid}` || #{unicorn_start_cmd}"
  end

  task :restart_ts, :roles => :app do
    thinking_sphinx.rebuild
  end

  after "deploy:migrate", "deploy:restart_ts"
  after "deploy:seed", "deploy:restart_ts"
end

set :keep_releases, 3

after "deploy", "deploy:cleanup"
