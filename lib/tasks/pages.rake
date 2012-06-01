namespace :pages do
  desc "copy pages from bd to /source"
  task :dump => :environment do

    def file_write(file, resource)
      file.write "h1. "
      file.write resource.name
      file.write "\n\n"
      file.write resource.text
    end

    Category.enabled.includes(:pages).each_with_index do |category, position|
      cat_directory = File.join(Rails.root, "source", "#{position}-#{category.url_match}")
      FileUtils.mkdir_p cat_directory
      File.open File.join(cat_directory, "--#{category.url_match}.textile"), 'w' do |file|
        file_write file, category
      end
      category.pages.enabled.each_with_index do |page, i|
        File.open File.join(cat_directory, "#{i}-#{page.url_match}.textile"), 'w' do |file|
          file_write file, page
        end
        print '.'
      end
      print '|'
    end

    Page.where(:category_id => nil).each do |page|
      File.open File.join(Rails.root, "source", "#{page.url_match}.textile"), 'w' do |file|
        file_write file, page
      end
      print '.'
    end

    puts "complete"
  end

  desc "import pages from /source to bd"
  task :import => :environment do
    def file_load(file, resource)
      content = File.read(file).partition("\n\n")
      resource.name = content[0][/^h1\.\s(.*)/, 1]
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
          file_load page_source, category
        else
          page = category.pages.find_or_initialize_by_url_match page_name[/\d+-(.*)\.textile$/, 1]
          page.show_order = page_name[/^(\d+)/, 1]
          file_load page_source, page
        end
        print "."
      end

      print "|"
    end

    homepage = Page.find_or_initialize_by_url_match 'home'
    homepage.show_order = -1
    file_load File.join(Rails.root, "source", "home.textile"), homepage

    Rails.cache.clear
    puts "complete"
  end
end
