Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  # dado el cambio q se hizo, solo se debe crear las 3 rutas de new create o destroy
  # ya no es util dado que se ha eliminado el metodo de recuperacion
  # de contrasenia dado incompatibilidad con render
  # resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "panel#index"
end
