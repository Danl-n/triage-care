#!/usr/bin/env bash
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails db:migrate

# Los seeds corren en cada deploy porque el plan gratuito de Render no tiene consola.
# Es seguro porque son idempotentes (find_or_create_by!).
bin/rails db:seed
