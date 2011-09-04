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
    return if @categories.nil? or @categories.empty?
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
              end
            end
          end
        end
      end
    end
    builder.doc.inner_html.html_safe
  end
  
  def selected_class condition, *other_classes
    other_classes << "selected" if condition
    {:class => other_classes*" "} unless other_classes.empty?
  end

  def textile(body, lite_mode=false)
    t = RedCloth.new(body)
    t.hard_breaks = false
    t.lite_mode = lite_mode
    t.to_html(:notestuff, :plusplus, :code)
  end
end
