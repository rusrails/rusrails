Urrr::Application.routes.draw do
  devise_for :admins

  root :to => "pages#index"
  match ":url_match" => "categories#show"
  match ":category_url_match/:url_match" => "pages#show"
end
