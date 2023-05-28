Page = StaticDocs::Page

StaticDocs.setup do
  source 'source'

  renderer :md do |body, page|
    engine = Rusrails::Markdown.new.engine
    engine.render(body).html_safe.tap do
      page.meta[:menu] = render 'pages/menu', markdown_renderer: engine.renderer
    end
  end
end
