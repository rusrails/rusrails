class Admin::DiscussionsController < Puffer::Base

  setup do
    group :discussions
  end

  index do
    field :title
    field :subject_id
    field :subject_type
    field :author_id
    field :author_type
    field :enabled
    field :updated_at
  end

  form do
    field :title
    field :subject_id
    field :subject_type
    field :author_id
    field :author_type
    field :enabled
  end

end
