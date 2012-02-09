Rusrails::Application.routes.draw do
  devise_for :users, :controllers => {:omniauth_callbacks => "omniauth_callbacks"}
  devise_scope :user do
    get '/users/auth/:provider' => 'omniauth_callbacks#passthru'
  end

  devise_for :admins, :controllers => {:registrations => "admins/registrations" }

  namespace "admin" do
    resources :categories
    resources :pages
    resources :users
    resources :discussions
    resources :says
    root :to => "dashboard#index"
  end

  resources :discussions, :only => [:index, :show, :new, :create] do
    resources :says, :only => :create
    get :preview, :on => :collection
  end

  resource :search, :only => :show, :controller => :search

  root :to => "pages#index"
  match ":url_match" => "categories#show"
  match ":category_url_match/:url_match" => "pages#show"
  match "*wrong" => "pages#404"
end
