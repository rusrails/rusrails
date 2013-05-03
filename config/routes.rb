Rusrails::Application.routes.draw do
  get 'map' => 'pages#map'

  resource :search, only: :show, controller: :search

  mount StaticDocs::Engine, at: "/"

end
