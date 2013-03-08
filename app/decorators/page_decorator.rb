# coding: utf-8
class PageDecorator < Draper::Decorator
  delegate_all

  def menu
    return unless renderer == 'md'
    h.render 'pages/menu', :markdown_renderer => markdown_renderer
  end

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

  def html
    case renderer
    when 'textile'
      h.textile(text).html_safe
    when 'md'
      markdown_html.html_safe
    else
      text.html_safe
    end
  end

  def comment_link
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.div :class => :well do
        if discussions.present?
          doc.h4 "Обсуждения к этой теме:"
          doc.ul do
            discussions.each do |discussion|
              doc.li do
                doc.a discussion.title, :href => h.discussion_path(discussion)
              end
            end
          end
        end
        doc.a "Оставить комментарий или задать вопрос",
              :href => h.new_discussion_path(:discussion => {:subject_id => id, :subject_type => 'Page'})
      end
    end
    builder.doc.inner_html.html_safe
  end
end
