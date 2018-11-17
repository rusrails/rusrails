namespace :yarn do
  desc "Install yarn"
  task :install, roles: :web do
    run "curl -sL https://deb.nodesource.com/setup_11.x | #{sudo} -E bash -"
    run "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | #{sudo} apt-key add -"
    run "echo 'deb https://dl.yarnpkg.com/debian/ stable main' | #{sudo} tee /etc/apt/sources.list.d/yarn.list"
    run "#{sudo} apt-get -y install nodejs yarn"
  end
  after "deploy:install", "yarn:install"
end
