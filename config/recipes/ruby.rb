set(:ruby_version, "2.4.1")
set(:bundle_cmd) { "bundle" }

# set(:rbenv_path, "~/.rbenv")
# set(:rbenv_build) { "#{rbenv_path}/plugins/ruby-build" }
# set(:rbenv_ruby_dir) {"#{rbenv_path}/versions/#{rbenv_ruby}" }
# set(:bundle_cmd) { "#{rbenv_path}/shims/bundle" }
# set(:rbenv_cmd) { "#{rbenv_path}/bin/rbenv" }

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
    run "gem install bundler --quiet --no-rdoc --no-ri"

    # run %Q{[ -d #{rbenv_path} ] || git clone https://github.com/rbenv/rbenv.git #{rbenv_path} && echo 'export PATH="#{rbenv_path}/shims:#{rbenv_path}/bin:$PATH"' >> ~/.bashrc}
    # run ". ~/.bashrc"
    # run %Q{eval "$(#{rbenv_cmd} init -)"}
    # run "[ -d #{rbenv_build} ] && (cd #{rbenv_build} && git pull && cd -) || git clone https://github.com/sstephenson/ruby-build.git #{rbenv_build}"
    # run "[ -d #{rbenv_ruby_dir} ] || #{rbenv_cmd} install #{ruby_version}"
    # run "gem install bundler --quiet --no-rdoc --no-ri"
    # run "#{rbenv_cmd} rehash"
  end
  after "deploy:install", "ruby:install"
end
