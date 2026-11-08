class Quirofano < ApplicationRecord
  enum :estado, { disponible: "disponible", ocupado: "ocupado", mantenimiento: "mantenimiento" },
       validate: true

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
end
