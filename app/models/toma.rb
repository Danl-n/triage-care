class Toma < ApplicationRecord
  belongs_to :atencion
  belongs_to :registrada_por, class_name: "User"

  # Escala ACVPU. Con prefix: true los métodos quedan legibles: conciencia_A?, conciencia_V?...
  enum :conciencia, { A: "A", C: "C", V: "V", P: "P", U: "U" }, prefix: true, validate: true

  # Hora de la toma: por defecto, el momento en que se registra.
  attribute :tomada_en, default: -> { Time.current }

  validates :tomada_en, presence: true
  validates :frecuencia_respiratoria, numericality: { only_integer: true, in: 0..80 }
  validates :spo2, numericality: { only_integer: true, in: 50..100 }
  validates :presion_sistolica, numericality: { only_integer: true, in: 40..300 }
  validates :pulso, numericality: { only_integer: true, in: 20..250 }
  validates :temperatura, numericality: { in: 30.0..45.0 }
  validates :con_oxigeno, inclusion: { in: [ true, false ] }
  validate :atencion_admite_tomas, on: :create

  scope :cronologicas, -> { order(:tomada_en) }

  private
    def atencion_admite_tomas
      return if atencion.blank? || atencion.abierta?

      errors.add(:base, :atencion_cerrada)
    end
end
