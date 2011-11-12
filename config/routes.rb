Urrr::Application.routes.draw do
  devise_for :users
  devise_for :admins, :controllers => {:registrations => "admin/registrations" }

  namespace "admin" do
    resources :categories, :except => :show
    resources :pages, :except => :show
    resources :discussions, :except => [:new, :create, :show]
    resources :says, :except => [:new, :create, :show]
    root :to => "says#index"
  end

  resources :discussions, :only => [:index, :show, :new, :create] do
    resources :says, :only => :create
  end
  resource :search, :only => :show, :controller => :search

  root :to => "pages#index"
  match ":url_match" => "categories#show"
  match ":category_url_match/:url_match" => "pages#show"
  match "*wrong" => "pages#404"
end
