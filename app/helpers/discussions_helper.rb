module DiscussionsHelper
  def author_of(resource)
    author = resource.author
    case author
    when Admin then "<b>#{author.name}</b>".html_safe
    when User then author.name
    else "неизвестный"
    end
  end
end
