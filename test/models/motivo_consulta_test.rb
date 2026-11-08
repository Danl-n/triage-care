require "test_helper"

class MotivoConsultaTest < ActiveSupport::TestCase
  def motivo_valido
    MotivoConsulta.new(nombre: "Quemadura", especialidad: especialidades(:emergencias),
                       requiere_quirofano: false, requiere_anestesista: false, duracion_estimada_minutos: 45)
  end

  test "guarda sus insumos requeridos con cantidad" do
    motivo = motivo_valido
    motivo.insumos_requeridos_attributes = [ { insumo_id: insumos(:gasas).id, cantidad: 3 } ]

    assert motivo.save
    assert_equal 3, motivo.insumos_requeridos.first.cantidad
  end

  test "descarta las filas de insumos enviadas en blanco" do
    motivo = motivo_valido
    motivo.insumos_requeridos_attributes = [ { insumo_id: "", cantidad: "" } ]

    assert motivo.save
    assert_empty motivo.insumos_requeridos
  end

  test "no permite repetir el mismo insumo" do
    motivo = motivo_valido
    motivo.insumos_requeridos_attributes = [
      { insumo_id: insumos(:gasas).id, cantidad: 1 },
      { insumo_id: insumos(:gasas).id, cantidad: 2 }
    ]

    assert_not motivo.valid?
    assert_includes motivo.errors.details[:base], { error: :insumos_repetidos }
  end

  test "la cantidad de cada insumo debe ser mayor que 0" do
    motivo = motivo_valido
    motivo.insumos_requeridos_attributes = [ { insumo_id: insumos(:gasas).id, cantidad: 0 } ]

    assert_not motivo.valid?
  end

  test "la duración estimada debe ser positiva" do
    motivo = motivo_valido
    motivo.duracion_estimada_minutos = 0

    assert_not motivo.valid?
  end
end
