class Admin::PagesController < Puffer::Base

  setup do
    group :pages
  end

  index do
    field :name
    field :url_match
    field :enabled
    field :show_order
  end

  form do
    field :name
    field :url_match
    field :text, html: {rows: 20}
    field :enabled
    field :show_order
  end

end
