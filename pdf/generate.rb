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

# Data Base
require 'textile-files'
##files = @@files

# -- local links BEGIN

# <a href="/path"> => <a href="#path">
def fix_local_links(files)
  local_links = []
  files.each do |f_path|
    local_links << path_to_link(f_path)
  end
  cnt = file_read(main_file_path)
  local_links.each do |link|
    anchor_name = link_to_anchor_href(link)
    cnt.gsub!('<a href="'+link+'"', '<a href="'+anchor_name+'"')
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
# '/getting-started-with-rails/this-guide-assumes' -> 'getting-started-with-rails_this-guide-assumes' ; _ -> ''
# a name=
def link_to_anchor_name(link)
  els = link.split('/')
  ret = els[1..els.size].join('')
  # wtf
  if ret == 'ruby-on-rails-security-guidecross-site-request-forgery-csrf'
    ret = 'cross-site-request-forgery-csrf'
  end
  return ret
end

# a href=
def link_to_anchor_href(link)
  els = link.split('/')
  ret = els[1..els.size].join('')
  # wtf
  if ret == 'ruby-on-rails-security-guidecross-site-request-forgery-csrf'
    ret = 'cross-site-request-forgery-csrf'
  end
  file_name = @@names2file_name[els[1]]
  ret = "#{file_name}##{ret}"
  return ret
end

def path_to_anchor_name(f_path)
  link_to_anchor_name path_to_link(f_path)
end


def get_all_files_from_parts(parts)
  ret = []
  parts.each do |part|
    files = part[:files]
    ret += files
  end
  return ret
end

# -- local links END


# all htmls in one file will be stored here
# pdf generated from this file
def main_file_path
  #'./out/_all.html'
  "./out/_#{@@name}.html"
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
    putc '.'
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
    putc '.' 
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


# absolute file system path
def fix_image_path
  p 'fix_image_path'
  cnt = file_read(main_file_path)
  cnt.gsub!('<img src="/assets', '<img src="./../../app/assets/images')
  file_write(main_file_path, cnt)
end

def fix_move_h1
  p 'fix_move_h1'
  cnt = file_read(main_file_path)
  cnt.sub!('<h1>', '<h0>')
  cnt.sub!('</h1>', '</h0>')
  (1..10).to_a.reverse.each do |header_level|
    cnt.gsub!("<h#{header_level}>", "<h#{header_level+1}>")
    cnt.gsub!("</h#{header_level}>", "</h#{header_level+1}>")
  end
  cnt.sub!('<h0>', '<h1>')
  cnt.sub!('</h0>', '</h1>')
  file_write(main_file_path, cnt)
end


def generate_pdf2(parts)
  p 'PDF generation'
  p 'based on wkhtmltopdf'
  pdf_file = 'rusrails.all.pdf'
  _parts = []
  parts.each do |part|
    _parts << "./out/_#{part[:name]}.html"
  end
  sources = _parts.join(' ')

  options = "--header-left [section] --header-center RusRails --header-right [page] --header-font-size 8 --header-spacing 5 --header-line --print-media-type --footer-html _footer.html"
  `#{PATH_TO_WKHTMLTOPDF} #{options} #{sources} #{pdf_file}`

  p "PDF generated: #{pdf_file}"
end


# obsolete
def generate_pdf
  p 'PDF generation'
  # based on Prince:
  # `#{PATH_TO_PRINCE} ./out/_all.html -o rusrails.pdf`
  # or
  p 'based on wkhtmltopdf'
  pdf_file = 'rusrails.test.pdfkit.pdf'
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
    # source = File.new(html_path)
    _parts = []
    @@parts.each do |part|
      _parts << "./out/_#{part[:name]}.html"
    end
    source = _parts.join(' ')
    p source
    kit = PDFKit.new(source)
    file = kit.to_file(pdf_file)
end


all_files = get_all_files_from_parts(@@parts)

@@parts.each do |part|
  @@name = part[:name]
  files = part[:files]
  textile2html(files)
  create_one_html_file(files)
  fix_image_path
  fix_local_links(all_files)
  fix_move_h1
end
generate_pdf2(@@parts)

