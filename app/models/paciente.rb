class Paciente < ApplicationRecord
  belongs_to :canton

  enum :sexo, { masculino: "masculino", femenino: "femenino" }, validate: true

  # Atributo virtual: no se guarda (la provincia se deduce del cantón), pero
  # permite el dropdown dependiente Provincia → Cantón y verificarlo en el back-end.
  attribute :provincia_id, :integer

  normalizes :nombres, :apellidos, with: ->(texto) { texto.strip }
  normalizes :cedula, with: ->(cedula) { cedula.strip }

  validates :cedula, presence: true, uniqueness: true, cedula_ecuatoriana: { allow_blank: true }
  validates :nombres, :apellidos, :fecha_nacimiento, presence: true
  validate :fecha_nacimiento_no_futura
  validate :canton_pertenece_a_la_provincia

  def provincia_id
    super || canton&.provincia_id
  end

  def nombre_completo
    "#{apellidos} #{nombres}"
  end

  private
    def fecha_nacimiento_no_futura
      return if fecha_nacimiento.blank?

      errors.add(:fecha_nacimiento, :no_futura) if fecha_nacimiento > Date.current
    end

    def canton_pertenece_a_la_provincia
      return if canton.blank? || self[:provincia_id].blank?

      errors.add(:canton, :no_pertenece_a_provincia) if canton.provincia_id != self[:provincia_id]
    end
end
