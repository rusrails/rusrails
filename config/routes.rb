Urrr::Application.routes.draw do
  devise_for :admins, :controllers => {:registrations => "admin/registrations" }
  
  namespace "admin" do
    resources :categories, :except => :show
    resources :pages, :except => :show
    root :to => "index#index"
  end

  root :to => "pages#index"
  match ":url_match" => "categories#show"
  match ":category_url_match/:url_match" => "pages#show"
end
