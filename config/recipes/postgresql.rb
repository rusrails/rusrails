set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_#{rails_env}" }
set_default(:postgresql_pid) { "/var/run/postgresql/9.2-main.pid" }

namespace :postgresql do
  desc "Install PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get -y install postgresql postgresql-contrib libpq-dev"
  end
  after "deploy:install", "postgresql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    #run %Q{#{sudo} -u postgres psql -c "drop database #{postgresql_database};"}
    #run %Q{#{sudo} -u postgres psql -c "drop user #{postgresql_user};"}
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with SUPERUSER LOGIN CREATEDB REPLICATION password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after "deploy:setup", "postgresql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgresql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  # it is done in 'deploy:symlink_configs'
  # after "deploy:finalize_update", "postgresql:symlink"
end
