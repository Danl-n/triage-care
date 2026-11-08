class SessionsController < ApplicationController
  # < = hereda
  # Recibe todo lo de ApplicationController incluida la protección
  # de autenticación
  allow_unauthenticated_access only: %i[ new create ]
  # hace una excepcion a la protección para las acciones
  # new (mostrar el formulario) y create (procesar el login)
  # i%[new create] es como se escribe [:new, :create] en Ruby
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Demasiados intentos. Intenta de nuevo en minutos." }
  # limita los intentos de login a 10 cada 3 minutos por cada IP

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      # params tiene todo lo que envio el formulario
      # .permit(:email_address, :password) solo deja pasar esos dos campos
      # ignora cualquier otro campo que se pueda agregar
      # User.authenticate_by() busca al usuario por correo y compara la
      # contrasenia con el hash bycrypt.Devuelve el usuario si todo coincide
      # if user=... guarda el resultado en user y a la vez lo evalua
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Correo o contraseña incorrectos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
