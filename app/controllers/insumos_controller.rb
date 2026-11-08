class InsumosController < ApplicationController
  before_action :set_insumo, only: %i[ show edit update destroy ]

  def index
    @insumos = Insumo.order(:nombre)
  end

  def show
  end

  def new
    @insumo = Insumo.new
  end

  def edit
  end

  def create
    @insumo = Insumo.new(insumo_params)

    if @insumo.save
      redirect_to @insumo, notice: "Insumo creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @insumo.update(insumo_params)
      redirect_to @insumo, notice: "Insumo actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @insumo.destroy
      redirect_to insumos_path, notice: "Insumo eliminado correctamente.", status: :see_other
    else
      redirect_to @insumo, alert: @insumo.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_insumo
      @insumo = Insumo.find(params.expect(:id))
    end

    def insumo_params
      params.expect(insumo: [ :nombre, :unidad, :stock_disponible ])
    end
end
