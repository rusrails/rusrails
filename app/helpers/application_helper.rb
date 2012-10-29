# encoding: utf-8
module ApplicationHelper
  def title
    if @page
      "Rusrails: "+@page.name
    elsif @category
      "Rusrails: "+@category.name
    else
      "Rusrails: Ruby on Rails по-русски"
    end
  end

  def menu
    @categories ||= Category.enabled
    return if @categories.empty?
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.ul :class => "menu" do
        @categories.each do |cat|
          doc.li selected_class(cat==@category, "category_pages") do
            doc.a cat.name, :href => cat.path
            if cat==@category
              doc.ul do
                @category.pages.enabled.each do |p|
                  doc.li selected_class(p==@page) do
                    doc.a p.name, :href => p.path
                  end
                end
              end # ul
            end
          end
        end # each
      end
    end
    builder.doc.inner_html.html_safe
  end

  def selected_class condition, *other_classes
    other_classes << "selected" if condition
    {:class => other_classes*" "} unless other_classes.empty?
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

  def comment_link(subject)
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.div :class => :discussions do
        if subject.discussions.present?
          doc.h4 "Обсуждения к этой теме:"
          doc.ul do
            subject.discussions.each do |discussion|
              doc.li do
                doc.a discussion.title, :href => discussion_path(discussion)
              end
            end
          end
        end
        doc.a "Оставить комментарий или задать вопрос",
              :href => new_discussion_path(:discussion => {:subject_id => subject.id, :subject_type => subject.class.to_s})
      end
    end
    builder.doc.inner_html.html_safe
  end
end
