class QuirofanosController < ApplicationController
  before_action :set_quirofano, only: %i[ show edit update destroy ]

  def index
    @quirofanos = Quirofano.order(:nombre)
  end

  def show
  end

  def new
    @quirofano = Quirofano.new
  end

  def edit
  end

  def create
    @quirofano = Quirofano.new(quirofano_params)

    if @quirofano.save
      redirect_to @quirofano, notice: "Quirófano creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @quirofano.update(quirofano_params)
      redirect_to @quirofano, notice: "Quirófano actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @quirofano.destroy!
    redirect_to quirofanos_path, notice: "Quirófano eliminado correctamente.", status: :see_other
  end

  private
    def set_quirofano
      @quirofano = Quirofano.find(params.expect(:id))
    end

    def quirofano_params
      params.expect(quirofano: [ :nombre, :estado ])
    end
end
