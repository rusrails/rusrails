#
# Standalone script for textile to pdf generation
#
# 
# Use RedCloth for textile to html.
# Use PrinceXML or wkhtmltopdf pdf engine for html to pdf.
#
# 1. gem install RedCloth
# 2. install pdf generation engine - price OR wkhtmltopdf
# 3 ./out - folder for outputs htmls
#
# this script placed in rusrails/pdf folder
#

# princexml - free for non-commerial 
# from http://www.princexml.com/download/
# for win32 Prince installations
# PATH_TO_PRINCE = "C:/Program Files/Prince/Engine/bin/prince.exe"

# wkhtmltopdf - free engine http://code.google.com/p/wkhtmltopdf/
#
# install binary engine, f.e. for windows
# http://wkhtmltopdf.googlecode.com/files/wkhtmltox-0.11.0_rc1-installer.exe
# full list: http://code.google.com/p/wkhtmltopdf/downloads/list
#
# then install ruby gem:
# gem install pdfkit
# 
# path to binary
PATH_TO_WKHTMLTOPDF = 'C:/Program Files/wkhtmltopdf/wkhtmltopdf.exe'


require 'redcloth'
require '../vendor/textile_extension'
RedCloth.include TextileExtensions

# Data Dase
require 'textile-files'
files = @@files

# -- local links BEGIN

# <a href="/path"> => <a href="#path">
def fix_local_links(files)
  local_links = []
  files.each do |f_path|
    local_links << path_to_link(f_path)
  end
  cnt = file_read(main_file_path)
  local_links.each do |link|
    anchor_name = link_to_anchor_name(link)
    cnt.gsub!('<a href="'+link+'"', '<a href="#'+anchor_name+'"')
  end
  file_write(main_file_path, cnt)
end

def get_anchor(f_path)
  "<a name='#{path_to_anchor_name(f_path)}'></a>"
end

# '0-getting-started-with-rails/--getting-started-with-rails.textile' ->
# '/getting-started-with-rails'
#
# '0-getting-started-with-rails/0-this-guide-assumes.textile' ->
# '/getting-started-with-rails/this-guide-assumes'
# TODO refactoring
def path_to_link(path)
  return '/home' if path == 'home.textile'
  els = path.split('/')
  dir_name = els[0]
  file_name = els[1]
  dir_name = dir_name.split('-')[1..dir_name.split('-').size].join('-')

  els2 = file_name.split('-')
  if (els2[0] == els2[1]) && (els2[0] == '')
    return "/#{dir_name}"
  else
    file_name = els2[1..els2.size].join('-').split('.')[0]
    return "/#{dir_name}/#{file_name}"
  end
end

# '/getting-started-with-rails' -> 'getting-started-with-rails'
# '/getting-started-with-rails/this-guide-assumes' -> 'getting-started-with-rails_this-guide-assumes'
def link_to_anchor_name(link)
  els = link.split('/')
  els[1..els.size].join('_')
end

def path_to_anchor_name(f_path)
  link_to_anchor_name path_to_link(f_path)
end

# -- local links END


# all htmls in one file will be stored here
# pdf generated from this file
def main_file_path
  './out/_all.html'
end


def file_read(file_path)
  File.read(file_path)
end

def file_write(file_path, cnt)
  File.open(file_path, 'wb') do |f|
    f << cnt
  end
end

def textile2html(files)
  p 'Work: textile2html'
  files.each do |file_path|
    p file_path
    file_path2 = file_path.tr('/', '_')

    source_path = "../source/#{file_path}"
    dest_path = "./out/#{file_path2}.html"

    text = file_read(source_path)

    #html_content = RedCloth.new(text).to_html

    t = RedCloth.new(text)
    t.hard_breaks = false
    t.lite_mode = false # lite_mode
    t.sanitize_html = true # sanitize
    html_content = t.to_html(:notestuff, :plusplus, :code)

    file_write(dest_path, html_content)
    #`redcloth ../source/#{file_path} > ./out/#{file_path2}.html`
  end
  p 'done'
end

def create_one_html_file(files)
  p 'Work: create_one_html_file'
  all_cnt = ''
  files.each do |file_path|
    p file_path
    file_path2 = file_path.tr('/', '_')
    cnt = file_read("./out/#{file_path2}.html")
    
    # add anchor at beginning of file
    cnt = get_anchor(file_path) + cnt

    all_cnt += cnt
  end

  layout = """<html>
  <head>
    <title>RusRails</title>
    <META http-equiv=Content-Type content='text/html; charset=utf-8'>
  </head>
  <body>
  {CONTENT}
  </body>
  </html>
  """

  all_pages = layout.gsub("{CONTENT}", all_cnt)
  file_write(main_file_path, all_pages)

  p 'done'
end

def generate_pdf
  p 'PDF generation'

  # based on Prince:
  # `#{PATH_TO_PRINCE} ./out/_all.html -o rusrails.pdf`
  # or

  p 'based on wkhtmltopdf'

  html_path = main_file_path
  pdf_file = 'rusrails.test.pdfkit.pdf'

  if File.exists?(html_path)
    require 'pdfkit'

    PDFKit.configure do |config|
      config.wkhtmltopdf = PATH_TO_WKHTMLTOPDF
      # see 'wkhtmltopdf-options.txt'
      # --header-font-size ==> :header_font_size
      config.default_options = {
        :page_size => 'A4', # by default
        :header_left => '[section]',
        :header_center => 'RusRails',
        :header_right => '[page]',
        :header_font_size => '8',
        :header_spacing => '5', # mm
        :header_line => true,
        :print_media_type => true
      }
    end

    kit = PDFKit.new(File.new(html_path))
    file = kit.to_file(pdf_file)
  end
end


# absolute file system path
def fix_image_path
  cnt = file_read(main_file_path)
  cnt.gsub!('<img src="/assets', '<img src="./../../app/assets/images')
  file_write(main_file_path, cnt)
end

textile2html(files)
create_one_html_file(files)
fix_image_path
fix_local_links(files)
generate_pdf
