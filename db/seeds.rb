# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_create_by!(email_address: ENV.fetch("TRIAGE_CARE_ADMIN_EMAIL", "admin@triagecare.ec")) do |user|
user.password = ENV.fetch("TRIAGE_CARE_ADMIN_PASSWORD")
  # User.find_or_create_by!(email_address:...) busca un usuario con el correo
  # si existe no hace nada y si no lo crea
  # ENV.fetch("TRIAGE_CARE_ADMIN_EMAIL","admin@triagecare.ec") lee variable
  # de entorno si no existe usa el valor por defecto
  # do |user| ... end solo se ejecuta si el usuario se esta creando
  # user.password = ENV.fetch("TIRAGE_CARE_ADMIN_PASSWORD")
  # password= no es una columna de la tabla es un atributo virtual que agrega
  # has_secure_password recibe contrasenia en texto pasa por bycrypt y guarda el hash
  # en password_digest
  # aqui ENV.fecth va sin valor por defecto a proposito, si se olvida definir la variable
  # el seed se detiene con un error
end
