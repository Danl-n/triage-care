class Canton < ApplicationRecord
  belongs_to :provincia
  has_many :pacientes, dependent: :restrict_with_error

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  validates :nombre, presence: true,
                     uniqueness: { scope: :provincia_id, case_sensitive: false }

  scope :de_provincia, ->(provincia_id) { where(provincia_id: provincia_id).order(:nombre) }
end
