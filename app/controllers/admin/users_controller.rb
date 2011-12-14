class Admin::UsersController < Puffer::Base

  setup do
    group :users
  end

  index do
    field :id
    field :email
    field :sign_in_count
    field :current_sign_in_at
    field :last_sign_in_at
    field :current_sign_in_ip
    field :last_sign_in_ip
    field :name
    field :banned
    field :oauth_id
    field :oauth
  end

  form do
    field :email
    field :password
    field :password_confirmation
    field :name
    field :banned
    field :oauth_id
    field :oauth
  end

end
