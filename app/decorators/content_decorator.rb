# coding: utf-8
class ContentDecorator < Draper::Decorator

  def markdown_engine
    @markdown_engine ||= Markdown.new.engine
  end

  def markdown_renderer
    @markdown_renderer ||= begin
      markdown_html
      markdown_engine.renderer
    end
  end

  def markdown_html
    @markdown_html ||= markdown_engine.render(text)
  end

  def textile_html(lite_mode = false, sanitize = false)
    t = RedCloth.new(text)
    t.hard_breaks = false
    t.lite_mode = lite_mode
    t.sanitize_html = sanitize
    t.to_html(:notestuff, :plusplus, :code, :rails_mark)
  end

  def html
    case renderer
    when 'textile'
      textile_html.html_safe
    when 'md'
      markdown_html.html_safe
    else
      text.html_safe
    end
  end
end
