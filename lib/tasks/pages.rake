namespace :pages do
  desc "import pages from /source to bd"
  task :import => :environment do
    def file_load(file, resource)
      content = File.read(file).partition("\n\n")
      resource.name = case resource.renderer
      when 'md'
        content[0][/^#\s(.*)/, 1]
      when 'textile'
        content[0][/^h1\.\s(.*)/, 1]
      else
        content[0].strip
      end
      resource.text = content[2]
      resource.save
    end

    source = File.join(Rails.root, "source")
    Dir.foreach(source) do |cat_name|
      cat_source = File.join(source, cat_name)
      next if cat_name == '.' || cat_name == '..' || File.file?(cat_source)

      category = Category.find_or_initialize_by_url_match cat_name[/\d+-(.*)$/, 1]
      category.show_order = cat_name[/^(\d+)/, 1]
      category.save

      Dir.foreach(cat_source) do |page_name|
        next if page_name == '.' || page_name == '..'
        page_source = File.join(cat_source, page_name)

        if page_name =~ /^--/
          category.renderer = page_name[/\--.*\.((?:textile|md))$/, 1]
          file_load page_source, category
        else
          page = category.pages.find_or_initialize_by_url_match page_name[/\d+-(.*)\.(?:textile|md)$/, 1]
          page.renderer = page_name[/\d+-.*\.((?:textile|md))$/, 1]
          page.show_order = page_name[/^(\d+)/, 1]
          file_load page_source, page
        end
        print "."
      end

      print "|"
    end

    homepage = Page.find_or_initialize_by_url_match 'home'
    homepage.renderer = 'md'
    homepage.show_order = -1
    file_load File.join(Rails.root, "source", "home.md"), homepage

    Rails.cache.clear
    puts "complete"
  end
end
