class TipoRed < ApplicationRecord
  has_many :hospitales_referencia, dependent: :restrict_with_error

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
end
