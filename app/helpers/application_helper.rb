module ApplicationHelper
  def menu
    return if @categories.nil? or @categories.empty?
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.ul :class => "menu" do
        @categories.each do |cat|
          doc.li selected_class(cat==@category) do
            doc.a cat.name, :href => cat.path
            if cat==@category
              doc.ul do
                @category.pages.active.each do |p|
                  doc.li do
                    doc.a p.name, :href => p.path
                  end
                end
              end
            end
          end
        end
      end
    end
    builder.doc.inner_html
  end
  
  def selected_class condition
    if condition
      {:class => "selected"}
    else
      {}
    end
  end
end
