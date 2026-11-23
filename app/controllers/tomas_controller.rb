# Las tomas son un registro clínico: no se editan ni se borran. Si hubo un error,
# se registra una toma nueva. Por eso solo hay new, create y show (ver config/routes.rb).
class TomasController < ApplicationController
  before_action :set_atencion

  def show
    @toma = @atencion.tomas.find(params.expect(:id))
  end

  def new
    @toma = @atencion.tomas.new
  end

  # El controlador solo orquesta: arma la toma, pide la valoración al core, guarda y redirige.
  def create
    @toma = @atencion.tomas.new(toma_params)
    @toma.registrada_por = Current.user

    if @toma.valid?
      Triage::ValoradorToma.new.valorar(@toma)
      @toma.save!
      redirect_to atencion_toma_path(@atencion, @toma), notice: "Toma registrada correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def set_atencion
      @atencion = Atencion.find(params.expect(:atencion_id))
    end

    # Solo los signos vienen del formulario: quién la registró sale de la sesión,
    # la hora es la actual y el resultado lo calcula el core.
    def toma_params
      params.expect(toma: [ :frecuencia_respiratoria, :spo2, :con_oxigeno, :presion_sistolica,
                            :pulso, :conciencia, :temperatura ])
    end
end
