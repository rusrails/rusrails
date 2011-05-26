module ApplicationHelper
  def menu
    return if @categories.nil? or @categories.empty?
    builder = Nokogiri::HTML::Builder.new do |doc|
      doc.ul :class => "menu" do
        @categories.each do |cat|
          doc.li do
            doc.a cat.name, :href => cat.path
          end
        end
      end
    end
    builder.doc.inner_html
  end
end
