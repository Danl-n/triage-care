class CantonesController < ApplicationController
  before_action :set_canton, only: %i[ show edit update destroy ]

  def index
    @cantones = Canton.includes(:provincia).order("provincias.nombre", :nombre).references(:provincia)
  end

  def show
  end

  def new
    @canton = Canton.new
  end

  def edit
  end

  def create
    @canton = Canton.new(canton_params)

    if @canton.save
      redirect_to @canton, notice: "Cantón creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @canton.update(canton_params)
      redirect_to @canton, notice: "Cantón actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @canton.destroy
      redirect_to cantones_path, notice: "Cantón eliminado correctamente.", status: :see_other
    else
      redirect_to @canton, alert: @canton.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_canton
      @canton = Canton.find(params.expect(:id))
    end

    def canton_params
      params.expect(canton: [ :nombre, :provincia_id ])
    end
end
