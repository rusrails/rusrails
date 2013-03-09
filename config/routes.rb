Rusrails::Application.routes.draw do
  root :to => "pages#index"

  get 'map' => 'pages#map'
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
    post :preview, :on => :collection
    get 'page/:page', :action => :index, :on => :collection
  end

  resource :search, :only => :show, :controller => :search

  get ":url_match" => "pages#show"
  match "*wrong" => "pages#not_found"
end
