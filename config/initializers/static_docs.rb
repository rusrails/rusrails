Page = StaticDocs::Page

StaticDocs.setup do
  source 'source'

  renderer :md do |body, page|
    engine = Markdown.new.engine
    engine.render(body).html_safe.tap do
      page.meta[:menu] = render 'pages/menu', markdown_renderer: engine.renderer
    end
  end

  renderer :textile do |page|
    t = RedCloth.new(page)
    t.hard_breaks = false
    t.lite_mode = false
    t.sanitize_html = false
    t.to_html(:notestuff, :plusplus, :code, :rails_mark).html_safe
  end
end
