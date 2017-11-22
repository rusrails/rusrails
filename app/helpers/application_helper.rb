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
        url: 'https://mkdev.me/?utm_source=rusrails&utm_medium=banner&utm_campaign=rusrails&utm_content=blackfriday',
        image: 'partners/mkdev/blackfriday.png'
      },

      # {
      #   url: 'https://mkdev.me/specializations?utm_source=rusrails&utm_medium=banner&utm_campaign=rusrails&utm_content=expertise',
      #   image: 'partners/mkdev/expertise.png'
      # },
      # {
      #   url: 'https://mkdev.me/mentors/aya-soft?utm_source=rusrails&utm_medium=banner&utm_campaign=rusrails&utm_content=ageev',
      #   image: 'partners/mkdev/ageev.png'
      # },
      # {
      #   url: 'https://mkdev.me/mentors/xiting?utm_source=rusrails&utm_medium=banner&utm_campaign=rusrails&utm_content=takarlikov',
      #   image: 'partners/mkdev/takarlikov.png'
      # },
      # {
      #   url: 'https://mkdev.me/mentors/zverok?utm_source=rusrails&utm_medium=banner&utm_campaign=rusrails&utm_content=shepelev',
      #   image: 'partners/mkdev/shepelev.png'
      # },
      # {
      #   url: 'https://mkdev.me/mentors/Mehonoshin?utm_source=rusrails&utm_medium=banner&utm_campaign=rusrails&utm_content=mekhonoshin',
      #   image: 'partners/mkdev/mekhonoshin.png'
      # },
    ].sample
  end
end
