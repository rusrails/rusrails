def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install software-properties-common"
  end

  desc 'Symlink all configs into current release'
  task :symlink_configs, roles: :app do
    s = "cd #{shared_path}/config && "
    s << "for i in `find . -type f | sed 's/^\\.\\///'` ; do "
    s << "echo \"create current/config/${i}\" ;"
    s << "rm -f #{release_path}/config/${i} ;"
    s << "ln -snf #{shared_path}/config/${i} #{release_path}/config/${i} ; done"
    run s
  end

  after "deploy:finalize_update", "deploy:symlink_configs"

end
