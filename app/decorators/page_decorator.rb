# coding: utf-8
class PageDecorator < ContentDecorator
  delegate_all

  def menu
    return unless renderer == 'md'
    h.render 'pages/menu', markdown_renderer: markdown_renderer
  end

  def comment_link
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.div class: :well do
        if discussions.present?
          doc.h4 "Обсуждения к этой теме:"
          doc.ul do
            discussions.each do |discussion|
              doc.li do
                doc.a discussion.title, href: h.discussion_says_path(discussion)
              end
            end
          end
        end
        doc.a "Оставить комментарий или задать вопрос", href: h.new_discussion_path(discussion: {subject_id: id, subject_type: 'Page'})
      end
    end
    builder.doc.inner_html.html_safe
  end
end
