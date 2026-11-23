class Atencion < ApplicationRecord
  ESTADOS_ABIERTOS = %w[ en_espera en_atencion ].freeze

  belongs_to :paciente
  belongs_to :motivo_consulta

  enum :estado, { en_espera: "en_espera", en_atencion: "en_atencion",
                  finalizada: "finalizada", derivada: "derivada" }, validate: true

  validates :hora_llegada, presence: true
  validate :hora_llegada_no_futura
  validate :paciente_sin_otra_atencion_abierta

  scope :abiertas, -> { where(estado: ESTADOS_ABIERTOS) }
  scope :recientes, -> { order(hora_llegada: :desc) }

  def abierta?
    estado.in?(ESTADOS_ABIERTOS)
  end

  private
    def hora_llegada_no_futura
      return if hora_llegada.blank?

      errors.add(:hora_llegada, :no_futura) if hora_llegada > Time.current
    end

    def paciente_sin_otra_atencion_abierta
      return if paciente_id.blank? || !abierta?

      otra_abierta = Atencion.abiertas.where(paciente_id: paciente_id).where.not(id: id).exists?
      errors.add(:paciente, :atencion_abierta) if otra_abierta
    end
end
