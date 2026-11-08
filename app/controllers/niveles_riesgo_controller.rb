# Los 4 niveles de riesgo se crean por seed. Aquí solo se consultan y se editan
# sus tiempos: por eso no hay new, create ni destroy (ver config/routes.rb).
class NivelesRiesgoController < ApplicationController
  before_action :set_nivel_riesgo, only: %i[ show edit update ]

  def index
    @niveles_riesgo = NivelRiesgo.por_prioridad
  end

  def show
  end

  def edit
  end

  def update
    if @nivel_riesgo.update(nivel_riesgo_params)
      redirect_to @nivel_riesgo, notice: "Nivel de riesgo actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_nivel_riesgo
      @nivel_riesgo = NivelRiesgo.find(params.expect(:id))
    end

    # Solo los tiempos son editables: nombre, prioridad y criterio quedan fijos.
    def nivel_riesgo_params
      params.expect(nivel_riesgo: [ :espera_maxima_minutos, :frecuencia_toma_minutos, :limite_derivacion_minutos ])
    end
end
