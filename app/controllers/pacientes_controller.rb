class PacientesController < ApplicationController
  before_action :set_paciente, only: %i[ show edit update destroy ]

  def index
    @pacientes = Paciente.includes(canton: :provincia).order(:apellidos, :nombres)
  end

  def show
  end

  def new
    @paciente = Paciente.new
  end

  def edit
  end

  def create
    @paciente = Paciente.new(paciente_params)

    if @paciente.save
      redirect_to @paciente, notice: "Paciente creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @paciente.update(paciente_params)
      redirect_to @paciente, notice: "Paciente actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @paciente.destroy!
    redirect_to pacientes_path, notice: "Paciente eliminado correctamente.", status: :see_other
  end

  private
    def set_paciente
      @paciente = Paciente.find(params.expect(:id))
    end

    # provincia_id no se guarda: viaja con el formulario para que el modelo
    # verifique que el cantón elegido pertenece a esa provincia.
    def paciente_params
      params.expect(paciente: [ :cedula, :nombres, :apellidos, :fecha_nacimiento, :sexo, :provincia_id, :canton_id ])
    end
end
