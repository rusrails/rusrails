require "bundler/capistrano"
require 'thinking_sphinx/deploy/capistrano'

set :application, "rusrails"

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :repository, "git://github.com/morsbox/urrr.git"  # Your clone URL
set :branch, "production"
set :scm, "git"
set :deploy_via, :remote_cache

dpath = "/home/hosting_mik-die/projects/rusrails"

set :user, "hosting_mik-die"

set :use_sudo, false
set :deploy_to, dpath
set :bundle_cmd, '/var/lib/gems/1.8/bin/bundle'
set :bundle_flags, "--deployment"

role :web, "hydrogen.locum.ru"
role :app, "hydrogen.locum.ru"
role :db,  "hydrogen.locum.ru", :primary => true

set :unicorn_rails, "/var/lib/gems/1.8/bin/unicorn_rails"
set :unicorn_conf, "/etc/unicorn/rusrails.mik-die.rb"
set :unicorn_pid, "/var/run/unicorn/rusrails.mik-die.pid"

# - for unicorn - #
namespace :deploy do
  task :copy_database_configuration do
    run "cp #{shared_path}/config/database.yml #{current_path}/config/database.yml"
  end
  after "deploy:symlink", "deploy:copy_database_configuration"

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

  after "deploy:copy_database_configuration", "deploy:migrate"

  desc "Seed the database with the required data"
  task :seed_database do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")

    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:seed"
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} pages:import"
  end
  after "deploy:migrate", "deploy:seed_database"

  desc "Start application"
  task :start, :roles => :app do
    run "#{unicorn_rails} -Dc #{unicorn_conf}"
  end

  desc "Stop application"
  task :stop, :roles => :app do
    run "[ -f #{unicorn_pid} ] && kill -QUIT `cat #{unicorn_pid}`"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "[ -f #{unicorn_pid} ] && kill -USR2 `cat #{unicorn_pid}` || #{unicorn_rails} -Dc #{unicorn_conf}"
  end

  task :restart_ts, :roles => :app do
    thinking_sphinx.rebuild
  end
  after "deploy:seed_database", "deploy:restart_ts"
end

set :keep_releases, 3

after "deploy", "deploy:cleanup"
