class Especialidad < ApplicationRecord
  has_many :medicos, dependent: :restrict_with_error
  has_many :motivos_consulta, dependent: :restrict_with_error

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
end
