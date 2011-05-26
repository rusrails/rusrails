Urrr::Application.routes.draw do
  root :to => "pages#index"
  match ":url_match" => "categories#show"
end
