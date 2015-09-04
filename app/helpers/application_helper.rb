# encoding: utf-8
module ApplicationHelper
  def title
    if @page
      "Rusrails: " + @page.title
    else
      "Rusrails: Ruby on Rails по-русски"
    end
  end

  def opengraph_config
    { og_type: "website",
      og_title: title,
      og_description: "Ruby on Rails русские руководства, учебники, статьи",
      og_url: request.original_url,
      og_image: "http://www.http://rusrails.ru/assets/rusrails.png"
    }
  end
end
