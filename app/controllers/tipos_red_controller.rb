class TiposRedController < ApplicationController
  before_action :set_tipo_red, only: %i[ show edit update destroy ]

  def index
    @tipos_red = TipoRed.order(:nombre)
  end

  def show
    @hospitales = @tipo_red.hospitales_referencia.order(:nombre)
  end

  def new
    @tipo_red = TipoRed.new
  end

  def edit
  end

  def create
    @tipo_red = TipoRed.new(tipo_red_params)

    if @tipo_red.save
      redirect_to @tipo_red, notice: "Tipo de red creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @tipo_red.update(tipo_red_params)
      redirect_to @tipo_red, notice: "Tipo de red actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @tipo_red.destroy
      redirect_to tipos_red_path, notice: "Tipo de red eliminado correctamente.", status: :see_other
    else
      redirect_to @tipo_red, alert: @tipo_red.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_tipo_red
      @tipo_red = TipoRed.find(params.expect(:id))
    end

    def tipo_red_params
      params.expect(tipo_red: [ :nombre, :descripcion ])
    end
end
