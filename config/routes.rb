Rusrails::Application.routes.draw do
  resource :search, only: :show, controller: :search

  mount StaticDocs::Engine, at: "/"

end
