class InsumoRequerido < ApplicationRecord
  belongs_to :motivo_consulta
  belongs_to :insumo

  validates :cantidad, numericality: { only_integer: true, greater_than: 0 }
end
