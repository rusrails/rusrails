# encoding: utf-8
module ApplicationHelper
  def title
    if @page
      "Rusrails: "+@page.name
    else
      "Rusrails: Ruby on Rails по-русски"
    end
  end

  def menu
    Page.matching("index").decorate.html
  end

  def render_text_of(model)
    case model.renderer
    when 'textile'
      textile(model.text)
    when 'md'
      Markdown.new.render(model.text)
    else
      model.text
    end
  end

  def textile(body, lite_mode=false, sanitize=false)
    t = RedCloth.new(body)
    t.hard_breaks = false
    t.lite_mode = lite_mode
    t.sanitize_html = sanitize
    t.to_html(:notestuff, :plusplus, :code, :rails_mark)
  end

  def safe_textile(body, lite_mode=false)
    textile(body, lite_mode, true)
  end

end
