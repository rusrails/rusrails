# encoding: utf-8
module DiscussionsHelper
  def author_of(resource)
    author = resource.author
    case author
      when Admin then "<span class='admin_name'>#{author.name}</span>".html_safe
      when User then author.name
    else "неизвестный"
    end
  end

  def preview_link
    link_to "Предварительный просмотр", preview_discussions_path, :id => :preview_link
  end
end
