class MedicosController < ApplicationController
  before_action :set_medico, only: %i[ show edit update destroy ]

  def index
    @medicos = Medico.includes(:especialidad).order(:apellidos, :nombres)
  end

  def show
    @turnos = @medico.turnos.cronologicos
  end

  def new
    @medico = Medico.new
  end

  def edit
  end

  def create
    @medico = Medico.new(medico_params)

    if @medico.save
      redirect_to @medico, notice: "Médico creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @medico.update(medico_params)
      redirect_to @medico, notice: "Médico actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @medico.destroy
      redirect_to medicos_path, notice: "Médico eliminado correctamente.", status: :see_other
    else
      redirect_to @medico, alert: @medico.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_medico
      @medico = Medico.find(params.expect(:id))
    end

    def medico_params
      params.expect(medico: [ :cedula, :nombres, :apellidos, :especialidad_id ])
    end
end
