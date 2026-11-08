class Insumo < ApplicationRecord
  has_many :insumos_requeridos, dependent: :restrict_with_error

  normalizes :nombre, :unidad, with: ->(texto) { texto.strip }

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
  validates :unidad, presence: true
  validates :stock_disponible, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
