class ProvinciasController < ApplicationController
  before_action :set_provincia, only: %i[ show edit update destroy cantones ]

  def index
    @provincias = Provincia.order(:codigo)
  end

  def show
    @cantones = @provincia.cantones.order(:nombre)
  end

  def new
    @provincia = Provincia.new
  end

  def edit
  end

  def create
    @provincia = Provincia.new(provincia_params)

    if @provincia.save
      redirect_to @provincia, notice: "Provincia creada correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @provincia.update(provincia_params)
      redirect_to @provincia, notice: "Provincia actualizada correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @provincia.destroy
      redirect_to provincias_path, notice: "Provincia eliminada correctamente.", status: :see_other
    else
      redirect_to @provincia, alert: @provincia.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # GET /provincias/:id/cantones — JSON para el dropdown dependiente Provincia → Cantón.
  def cantones
    render json: @provincia.cantones.order(:nombre).select(:id, :nombre)
  end

  private
    def set_provincia
      @provincia = Provincia.find(params.expect(:id))
    end

    def provincia_params
      params.expect(provincia: [ :codigo, :nombre ])
    end
end
