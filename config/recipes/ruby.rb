set(:ruby_version, "2.4.1")
set(:bundle_cmd) { "bundle" }

namespace :ruby do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y install gcc libc6-dev build-essential libssl-dev libreadline-dev zlib1g-dev ca-certificates autoconf automake bison libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libyaml-dev pkg-config sqlite3 libgmp-dev"
    run "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
    run "curl -sSL https://get.rvm.io | bash -s stable"
    run "source ~/.rvm/scripts/rvm"
    run "type rvm | head -n 1"
    run "rvm install #{ruby_version}" # if it fails, just run install again
    run "rvm use #{ruby_version} --default"
    run "gem update --system"
    run "gem install bundler --quiet --no-rdoc --no-ri"
  end
  after "deploy:install", "ruby:install"
end
