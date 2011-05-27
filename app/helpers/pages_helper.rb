module PagesHelper
  def get_index_of_current_page
    @pages.find_index @page if @page and @pages
  end
  
  def prev_page_link
    return unless n = get_index_of_current_page 
    link_to @pages[n-1].name, @pages[n-1].path, :class => "prev_page" if n>0
  end
  
  def next_page_link
    return unless n = get_index_of_current_page 
    link_to @pages[n+1].name, @pages[n+1].path, :class => "next_page" if n<@pages.length-1
  end
end
