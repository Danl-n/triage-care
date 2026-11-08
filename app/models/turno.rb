class Turno < ApplicationRecord
  belongs_to :medico

  enum :modalidad, { presencial: "presencial", de_llamada: "de_llamada" }, validate: true

  # Atributo virtual: no se guarda (la especialidad se deduce del médico), pero
  # permite el dropdown dependiente Especialidad → Médico y verificarlo en el back-end.
  attribute :especialidad_id, :integer

  validates :inicio, :fin, presence: true
  validates :tiempo_llegada_minutos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :fin_posterior_al_inicio
  validate :medico_pertenece_a_la_especialidad
  validate :tiempo_llegada_segun_modalidad
  validate :sin_cruce_con_otros_turnos_del_medico

  scope :cronologicos, -> { order(:inicio) }

  def especialidad_id
    super || medico&.especialidad_id
  end

  private
    def fin_posterior_al_inicio
      return if inicio.blank? || fin.blank?

      errors.add(:fin, :posterior_al_inicio) if fin <= inicio
    end

    def medico_pertenece_a_la_especialidad
      return if medico.blank? || self[:especialidad_id].blank?

      errors.add(:medico, :no_pertenece_a_especialidad) if medico.especialidad_id != self[:especialidad_id]
    end

    def tiempo_llegada_segun_modalidad
      return if tiempo_llegada_minutos.blank? || modalidad.blank?

      if presencial? && tiempo_llegada_minutos.positive?
        errors.add(:tiempo_llegada_minutos, :debe_ser_cero_si_presencial)
      elsif de_llamada? && tiempo_llegada_minutos.zero?
        errors.add(:tiempo_llegada_minutos, :requerido_si_de_llamada)
      end
    end

    def sin_cruce_con_otros_turnos_del_medico
      return if medico_id.blank? || inicio.blank? || fin.blank?

      cruce = Turno.where(medico_id: medico_id)
                   .where.not(id: id)
                   .where("inicio < ? AND fin > ?", fin, inicio)
                   .exists?
      errors.add(:base, :turno_cruzado) if cruce
    end
end
