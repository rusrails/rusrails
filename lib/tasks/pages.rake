namespace :pages do
  desc "Cleanup old pages"
  task :cleanup => :environment do
    source = Rails.root.join "source"
    config = YAML.load IO.read File.join source, 'pages.yml'
    actual_page_urls = config['pages'].map{ |page| page['url'] }
    Page.where('url_match not in (?)', actual_page_urls).destroy_all
  end

  desc "import pages from /source to bd"
  task :import => :environment do
    source = Rails.root.join "source"
    config = YAML.load IO.read File.join source, 'pages.yml'
    config['pages'].each_with_index do |data, index|
      page = Page.find_or_initialize_by_url_match(data['url'])
      page.renderer = data['file'][/\.*\.((?:textile|md))$/, 1]
      page.show_order = index - 1
      page.name = data['title']
      page.text = File.read File.join(source, data['file'])
      page.save
    end
  end
end
