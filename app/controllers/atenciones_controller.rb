class AtencionesController < ApplicationController
  before_action :set_atencion, only: %i[ show edit update destroy ]

  def index
    @atenciones = Atencion.includes(:paciente, :motivo_consulta).recientes
  end

  def show
  end

  def new
    @atencion = Atencion.new(hora_llegada: Time.current.change(sec: 0))
  end

  def edit
  end

  def create
    @atencion = Atencion.new(atencion_params)

    if @atencion.save
      redirect_to @atencion, notice: "Atención registrada correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @atencion.update(atencion_params)
      redirect_to @atencion, notice: "Atención actualizada correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @atencion.destroy
      redirect_to atenciones_path, notice: "Atención eliminada correctamente.", status: :see_other
    else
      redirect_to @atencion, alert: @atencion.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_atencion
      @atencion = Atencion.find(params.expect(:id))
    end

    # usa_escala_spo2_2 no se recibe del formulario: activarlo desde la interfaz
    # queda para otra entrega (por ahora se fija por seed o consola).
    def atencion_params
      params.expect(atencion: [ :paciente_id, :motivo_consulta_id, :hora_llegada, :estado ])
    end
end
