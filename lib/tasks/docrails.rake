require 'git'

namespace :docrails do
  desc 'Current status of translations'

  task status: :environment do
    docrails  # pull

    known_guides = (config['pages'] + config['plan'] + config['old']).map { |page| page['file'] }
    all_guides = Dir["#{docrails_path}/guides/source/*.md"].map { |file| file[/[^\/]+\z/]}

    puts 'New guides: ', (all_guides - known_guides).join(', ')
    puts 'Removed guides: ', (known_guides - all_guides).join(', ')

    stats = []

    config['pages'].each do |page|
      file = "guides/source/#{page['file']}"
      stat = docrails.diff(page['revision']).path(file).stats
      log = docrails.log(1).path(file).first
      outdated = log.author_date.to_date - Date.strptime(page['date'], '%d/%m/%Y')
      stats << page.merge(stat[:total])
                            .merge(objectish: log.objectish, new_date: log.author_date, outdated: outdated.to_i)
    end

    stats.sort_by! { |stat| stat[:lines] + stat[:outdated] }

    stats.map do |stat|
      puts '%40.40s: +/- %4s/%4s, outdated %4s days (%s %s)' % [stat['file'], stat[:insertions], stat[:deletions],
                                                               stat[:outdated], stat[:objectish],
                                                               stat[:new_date].strftime('%d/%m/%Y')]
    end
  end

  desc "make diff (use rake 'docrails:diff[file_name]' > diff.diff)"

  task :diff, [:file_name] => :environment do |_, args|
    page = config['pages'].detect { |page| page['file'] == args.file_name }
    if page
      file = "guides/source/#{page['file']}"
      log = docrails.log(1).path(file).first
      puts "-" * 80
      puts "    revision: #{log.objectish}"
      puts "    date:     #{log.author_date.strftime('%d/%m/%Y')}"
      puts "-" * 80
      puts docrails.diff(page['revision']).path(file).first.patch
    else
      puts "Page #{args.file_name} not found!"
    end

  end

  def docrails
    @docrails ||= if Dir.exists?(docrails_path)
      Git.open(docrails_path).tap(&:pull)
    else
      Git.clone 'git@github.com:rails/docrails.git', 'docrails', path: docrails_path(false)
    end
  end

  def docrails_path(inside = true)
    path = ['tmp', inside ? 'docrails' : nil].compact
    Rails.root.join(*path)
  end

  def config
    @config = YAML.load IO.read Rails.root.join 'source', 'index.yml'
  end


end
