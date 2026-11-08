Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]

  root "panel#index"

  # Ubicación (dropdown dependiente Provincia → Cantón)
  resources :provincias do
    get :cantones, on: :member
  end
  resources :cantones
  resources :pacientes

  # Personal médico (dropdown dependiente Especialidad → Médico)
  resources :especialidades do
    get :medicos, on: :member
  end
  resources :medicos
  resources :turnos

  # Recursos
  resources :quirofanos
  resources :insumos
  resources :motivos_consulta

  # Derivación
  resources :tipos_red
  resources :hospitales_referencia

  # Los 4 niveles se crean por seed: solo se consultan y se editan.
  resources :niveles_riesgo, only: %i[ index show edit update ]

  get "up" => "rails/health#show", as: :rails_health_check
end
