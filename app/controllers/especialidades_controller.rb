class EspecialidadesController < ApplicationController
  before_action :set_especialidad, only: %i[ show edit update destroy medicos ]

  def index
    @especialidades = Especialidad.order(:nombre)
  end

  def show
    @medicos = @especialidad.medicos.order(:apellidos, :nombres)
  end

  def new
    @especialidad = Especialidad.new
  end

  def edit
  end

  def create
    @especialidad = Especialidad.new(especialidad_params)

    if @especialidad.save
      redirect_to @especialidad, notice: "Especialidad creada correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @especialidad.update(especialidad_params)
      redirect_to @especialidad, notice: "Especialidad actualizada correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @especialidad.destroy
      redirect_to especialidades_path, notice: "Especialidad eliminada correctamente.", status: :see_other
    else
      redirect_to @especialidad, alert: @especialidad.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # GET /especialidades/:id/medicos — JSON para el dropdown dependiente Especialidad → Médico.
  def medicos
    opciones = Medico.de_especialidad(@especialidad.id).map do |medico|
      { id: medico.id, nombre: medico.nombre_completo }
    end
    render json: opciones
  end

  private
    def set_especialidad
      @especialidad = Especialidad.find(params.expect(:id))
    end

    def especialidad_params
      params.expect(especialidad: [ :nombre ])
    end
end
