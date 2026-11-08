class HospitalesReferenciaController < ApplicationController
  before_action :set_hospital_referencia, only: %i[ show edit update destroy ]

  def index
    @hospitales_referencia = HospitalReferencia.includes(:tipo_red).order(:nombre)
  end

  def show
  end

  def new
    @hospital_referencia = HospitalReferencia.new
  end

  def edit
  end

  def create
    @hospital_referencia = HospitalReferencia.new(hospital_referencia_params)

    if @hospital_referencia.save
      redirect_to @hospital_referencia, notice: "Hospital de referencia creado correctamente."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @hospital_referencia.update(hospital_referencia_params)
      redirect_to @hospital_referencia, notice: "Hospital de referencia actualizado correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @hospital_referencia.destroy!
    redirect_to hospitales_referencia_path, notice: "Hospital de referencia eliminado correctamente.", status: :see_other
  end

  private
    def set_hospital_referencia
      @hospital_referencia = HospitalReferencia.find(params.expect(:id))
    end

    def hospital_referencia_params
      params.expect(hospital_referencia: [ :nombre, :tipo_red_id, :telefono ])
    end
end
