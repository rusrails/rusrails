# encoding: utf-8
module ApplicationHelper
  def title
    if @page
      "Rusrails: " + @page.name
    else
      "Rusrails: Ruby on Rails по-русски"
    end
  end

  def safe_markdown(body)
    sanitize Markdown.new.render(body)
  end

end
