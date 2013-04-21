Rusrails::Application.routes.draw do
  root to: "pages#index"

  get 'map' => 'pages#map'

  resource :search, only: :show, controller: :search

  get ":url_match" => "pages#show"
  match "*wrong" => "pages#not_found"
end
