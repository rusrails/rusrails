require 'git'

namespace :docrails do
  desc 'Current status of translations'

  task status: :environment do
    docrails  # pull

    known_guides = (config['pages'] + config['plan'] + config['old']).map { |page| page['file'] }
    all_guides = Dir["#{docrails_path}/guides/source/*.md"].map { |file| file[/[^\/]+\z/]}
    new_guides = all_guides - known_guides
    removed_guides = known_guides - all_guides

    puts "New guides: #{new_guides.join(', ')}" if new_guides.present?
    puts "Removed guides: #{removed_guides.join(', ')}" if removed_guides.present?

    images_stat = docrails.diff(config['images']['revision']).path('guides/assets/images').stats
    images_stat[:files].reject! { |file, _| file == 'guides/assets/images/favicon.ico' }
    if images_stat[:files].present?
      puts "Updated images:"
      images_stat[:files].each { |file, _| puts "  - %s" % file }
    end

    puts

    stats = []

    config['pages'].each do |page|
      file = "guides/source/#{page['file']}"
      stat = docrails.diff(page['revision']).path(file).stats
      log = docrails.log(1).path(file).first
      outdated = log.author_date.to_date - Date.strptime(page['date'], '%d/%m/%Y')
      stats << page.merge(stat[:total])
                   .merge(objectish: log.objectish, new_date: log.author_date, outdated: outdated.to_i)
    end

    config['plan'].each do |page|
      file = "guides/source/#{page['file']}"
      stat = docrails.diff('4b825dc642cb6eb9a060e54bf8d69288fbee4904').path(file).stats
      full_log = docrails.log.path(file)
      log = full_log.first
      init = full_log.last
      stats << page.merge(stat[:total])
                   .merge(new: true, outdated: (Date.current - init.author_date.to_date).to_i)
                   .merge(objectish: log.objectish, new_date: log.author_date)
    end

    stats.sort_by! { |stat| stat[:lines] + stat[:outdated] }

    stats.map do |stat|
      score = stat[:lines] + stat[:outdated]
      color = case
      when stat[:new] then 34
      when score < 0 then 37
      when 0 === score then 90
      when (1..200) === score then 32
      when (201..400) === score then 33
      when (401..700) === score then 31
      else 91
      end

      puts "\e[%sm%s %55.55s: +/- %4s/%4s, outdated %4s days (%s %s)\e[0m" %
            [color, stat[:new] ? '*' : ' ', stat['file'], stat[:insertions], stat[:deletions],
             stat[:outdated], stat[:objectish], stat[:new_date].strftime('%d/%m/%Y')]
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
    @docrails ||= if Dir.exist?(docrails_path)
      Git.open(docrails_path).tap do |git|
        git.pull('origin', 'main')
      rescue
        puts 'Cannot access remote rails repo, using local copy'
      end
    else
      Git.clone 'git@github.com:rails/rails.git', 'rails', path: docrails_path(false)
    end
  end

  def docrails_path(inside = true)
    path = ['tmp', inside ? 'rails' : nil].compact
    Rails.root.join(*path)
  end

  def config
    @config ||= YAML.load IO.read Rails.root.join 'source', 'index.yml'
  end
end
