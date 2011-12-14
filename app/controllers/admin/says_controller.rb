class Admin::SaysController < Puffer::Base

  setup do
    group :says
  end

  index do
    field :text
    field :discussion_id
    field :author_id
    field :author_type
    field :enabled
  end

  form do
    field :text
    field :discussion_id
    field :author_id
    field :author_type
    field :enabled
  end

end
