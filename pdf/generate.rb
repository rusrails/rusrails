# 
# Use 'redcloth' console command, for textile to html.
# Use prince pdf engine for html to pdf.
#
# 1. gem install RedCloth
# 2. need to download free version of PDF generator
#    from http://www.princexml.com/download/
# 3 ./out - folder for outputs htmls
#
# this script placed in rusrails/pdf folder
#

# for win32 Prince installations
PATH_TO_PRINCE = "C:/Program Files/Prince/Engine/bin/prince.exe"

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


def textile2html(files)
  p 'Work: textile2html'
  files.each do |file_path|
    p file_path
    file_path2 = file_path.tr('/', '_')
    `redcloth ../source/#{file_path} > ./out/#{file_path2}.html`
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

  # <ruby> </ruby>
  all_cnt.gsub!('<ruby>', '<pre>')
  all_cnt.gsub!('</ruby>', '</pre>')

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

  File.open('./out/_all.html', 'w') do |f|
    f << all_pages
  end
  p 'done'
end

def generate_pdf
  `#{PATH_TO_PRINCE} ./out/_all.html -o rusrails.pdf`
end


textile2html(files)
create_one_html_file(files)
generate_pdf