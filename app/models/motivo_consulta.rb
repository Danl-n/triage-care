class MotivoConsulta < ApplicationRecord
  belongs_to :especialidad
  has_many :insumos_requeridos, dependent: :destroy
  has_many :insumos, through: :insumos_requeridos

  accepts_nested_attributes_for :insumos_requeridos, allow_destroy: true, reject_if: :all_blank

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
  validates :duracion_estimada_minutos, numericality: { only_integer: true, greater_than: 0 }
  validates :requiere_quirofano, :requiere_anestesista, inclusion: { in: [ true, false ] }
  validate :sin_insumos_repetidos

  private
    def sin_insumos_repetidos
      ids = insumos_requeridos.reject(&:marked_for_destruction?).map(&:insumo_id).compact
      errors.add(:base, :insumos_repetidos) if ids.uniq.size != ids.size
    end
end
