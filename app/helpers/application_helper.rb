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
    {
      og_type: "website",
      og_title: title,
      og_description: "Ruby on Rails руководства, учебники, статьи на русском языке",
      og_url: request.original_url,
      og_image: "http://rusrails.ru/assets/rusrails.png"
    }
  end

  def mkdev_random_banner
    [
      {
        url: 'http://mkdev.me/?utm_source=rusrails&utm_medium=banner&utm_campaign=expertise2',
        image: 'partners/mkdev/expertise-2.png'
      },
      {
        url: 'http://mkdev.me/?utm_source=rusrails&utm_medium=banner&utm_campaign=rubyonrails',
        image: 'partners/mkdev/ror.png'
      },
      {
        url: 'https://mkdev.me/mentors/zverok?utm_source=rusrails&utm_medium=banner&utm_campaign=rusrails&utm_content=shepelev',
        image: 'partners/mkdev/shepelev.png'
      },
    ].sample
  end
end
