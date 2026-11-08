class NivelRiesgo < ApplicationRecord
  # Los 4 niveles se cargan por seed; desde el admin solo se editan los tiempos.
  validates :nombre, :criterio, presence: true
  validates :prioridad, uniqueness: true
  validates :espera_maxima_minutos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :frecuencia_toma_minutos, :limite_derivacion_minutos,
            numericality: { only_integer: true, greater_than: 0 }

  scope :por_prioridad, -> { order(:prioridad) }
end
