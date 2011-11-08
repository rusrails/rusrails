module DiscussionsHelper
  def author_of(resource)
    author = resource.author
    case author
    when Admin then "<span class='admin_name'>#{author.name}</span>".html_safe
    when User then author.name
    else "неизвестный"
    end
  end
end
