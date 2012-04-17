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


files = ['home.textile']

in_folder = '0-getting-started-with-rails/'
files += %w[
  --getting-started-with-rails.textile
  0-this-guide-assumes.textile
  1-what-is-rails.textile
  2-creating-a-new-rails-project.textile
  3-hello-rails.textile
  5-creating-a-resource.textile
  6-adding-a-second-model.textile
  7-refactoring.textile
  8-deleting-comments.textile
  9-security.textile
  10-building-a-multi-model-form.textile
  11-view-helpers.textile
  12-whats-next.textile
  13-configuration-gotchas.textile
].map{|file_name| in_folder + file_name }


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
    cnt = File.read("./out/#{file_path2}.html")
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

#textile2html(files)
#create_one_html_file(files)
#fix_image_path
generate_pdf