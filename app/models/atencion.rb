class Atencion < ApplicationRecord
  ESTADOS_ABIERTOS = %w[ en_espera en_atencion ].freeze

  belongs_to :paciente
  belongs_to :motivo_consulta
  has_many :tomas, dependent: :restrict_with_error
  has_one :ultima_toma, -> { order(tomada_en: :desc) }, class_name: "Toma"

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

  # prioridad_riesgo y espera_maxima_hasta (junto con hora_llegada) son lo que necesita
  # Triage::PriorizadorCola. Salen de la última toma; son nil si todavía no hay tomas.
  def prioridad_riesgo
    ultima_toma&.nivel_riesgo&.prioridad
  end

  def espera_maxima_hasta
    ultima_toma&.espera_maxima_hasta
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
