#!/usr/bin/env bash
#Shebang: indica a linux "ejecuta este archivo con bash"
set -o errexit #si falla cualquier comando se detiene el script

bundle install # instala en el servidor de render las gemas de Gemfile.lock
bin/rails assets:precompile # prepara los archivos css y js para produccion
bin/rails db:migrate # aplica las migraciones pendientes en la base de render
bin/rails db:seed # crea el usuario admin

#los seeds van aca por que en free render no tiene consola, asi que los seed corren
#en cada deploy