class ColaController < ApplicationController
  def index
    en_espera = Atencion.en_espera
                        .includes(:paciente, :motivo_consulta, ultima_toma: :nivel_riesgo)
                        .order(:hora_llegada)

    # Sin toma no hay nivel de riesgo: esas atenciones se muestran aparte, por orden de llegada.
    @sin_valorar, valoradas = en_espera.partition { |atencion| atencion.ultima_toma.nil? }

    @priorizador = Triage::PriorizadorCola.new
    @cola = @priorizador.ordenar(valoradas)
  end
end
