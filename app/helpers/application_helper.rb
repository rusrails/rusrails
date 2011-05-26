module ApplicationHelper
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
end
