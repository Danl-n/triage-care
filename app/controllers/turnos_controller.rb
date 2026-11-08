class TurnosController < ApplicationController
  before_action :set_turno, only: %i[ show edit update destroy ]

  def index
    @turnos = Turno.includes(medico: :especialidad).cronologicos
  end

  def show
  end

  def new
    @turno = Turno.new(modalidad: "presencial")
  end

  def edit
  end

  def create
    @turno = Turno.new(turno_params)

    if @turno.save
      redirect_to @turno, notice: "Turno creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @turno.update(turno_params)
      redirect_to @turno, notice: "Turno actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @turno.destroy!
    redirect_to turnos_path, notice: "Turno eliminado correctamente.", status: :see_other
  end

  private
    def set_turno
      @turno = Turno.find(params.expect(:id))
    end

    # especialidad_id no se guarda: viaja con el formulario para que el modelo
    # verifique que el médico elegido pertenece a esa especialidad.
    def turno_params
      params.expect(turno: [ :especialidad_id, :medico_id, :inicio, :fin, :modalidad, :tiempo_llegada_minutos ])
    end
end
