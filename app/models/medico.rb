class Medico < ApplicationRecord
  belongs_to :especialidad
  has_many :turnos, dependent: :restrict_with_error

  normalizes :nombres, :apellidos, with: ->(texto) { texto.strip }
  normalizes :cedula, with: ->(cedula) { cedula.strip }

  validates :cedula, presence: true, uniqueness: true, cedula_ecuatoriana: { allow_blank: true }
  validates :nombres, :apellidos, presence: true

  scope :de_especialidad, ->(especialidad_id) { where(especialidad_id: especialidad_id).order(:apellidos, :nombres) }

  def nombre_completo
    "#{apellidos} #{nombres}"
  end
end
