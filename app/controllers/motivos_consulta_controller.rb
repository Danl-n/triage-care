class MotivosConsultaController < ApplicationController
  FILAS_VACIAS_DE_INSUMOS = 3

  before_action :set_motivo_consulta, only: %i[ show edit update destroy ]

  def index
    @motivos_consulta = MotivoConsulta.includes(:especialidad).order(:nombre)
  end

  def show
    @insumos_requeridos = @motivo_consulta.insumos_requeridos.includes(:insumo).order("insumos.nombre").references(:insumo)
  end

  def new
    @motivo_consulta = MotivoConsulta.new
    agregar_filas_vacias
  end

  def edit
    agregar_filas_vacias
  end

  def create
    @motivo_consulta = MotivoConsulta.new(motivo_consulta_params)

    if @motivo_consulta.save
      redirect_to @motivo_consulta, notice: "Motivo de consulta creado correctamente."
    else
      agregar_filas_vacias
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @motivo_consulta.update(motivo_consulta_params)
      redirect_to @motivo_consulta, notice: "Motivo de consulta actualizado correctamente.", status: :see_other
    else
      agregar_filas_vacias
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @motivo_consulta.destroy!
    redirect_to motivos_consulta_path, notice: "Motivo de consulta eliminado correctamente.", status: :see_other
  end

  private
    def set_motivo_consulta
      @motivo_consulta = MotivoConsulta.find(params.expect(:id))
    end

    # Filas en blanco para agregar insumos; las que se envían vacías se descartan (reject_if: :all_blank).
    def agregar_filas_vacias
      FILAS_VACIAS_DE_INSUMOS.times { @motivo_consulta.insumos_requeridos.build }
    end

    def motivo_consulta_params
      params.expect(motivo_consulta: [
        :nombre, :especialidad_id, :requiere_quirofano, :requiere_anestesista, :duracion_estimada_minutos,
        insumos_requeridos_attributes: [ [ :id, :insumo_id, :cantidad, :_destroy ] ]
      ])
    end
end
