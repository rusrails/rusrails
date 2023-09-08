require 'git'

namespace :deploy do
  task start: %i[
    clean_deploy_folder
    assets:clobber
    assets:precompile
    copy_public
    assets:clobber
    static_docs:import
    start_rails_server
    generate_pages
    stop_rails_server
    commit_and_push
    done
  ]

  task :clean_deploy_folder do
    FileUtils.rm_rf 'deploy' if File.exist? 'deploy'
  end

  task :copy_public do
    FileUtils.cp_r 'public', 'deploy'
  end

  task :start_rails_server do
    # `rails s -d` # TODO: doesn't work, probably some legacy setup, need to compare with new Rails app setup.
    `RAILS_ENV=production rails s > /dev/null &`
    sleep 3
  end

  task generate_pages: :environment do
    Dir.chdir 'deploy' do
      Page.find_each do |page|
        File.open("#{page.path}.html", 'wb:UTF-8') do |file|
          file << URI.open("http://localhost:3000/#{page.path}").read
        end
      end
      File.open("search.html", 'wb:UTF-8') do |file|
        file << URI.open("http://localhost:3000/search").read
      end
    end
  end

  task :stop_rails_server do
    `cat tmp/pids/server.pid | xargs -I {} kill {}`
  end

  task :commit_and_push do
    pages = '../rusrails.github.io'
    git = Git.open(pages)
    git.pull
    git.remove('*', recursive: true)
    FileUtils.cp_r 'deploy/.', pages
    git.add(all: true)
    git.commit("Generated version #{Time.now}")
    git.push
  end

  task :done do
    puts 'Done!'
  end
end
