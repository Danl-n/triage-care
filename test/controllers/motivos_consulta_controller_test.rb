require "test_helper"

class MotivosConsultaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @motivo_consulta = motivos_consulta(:herida)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get motivos_consulta_path
    assert_response :success

    get motivo_consulta_path(@motivo_consulta)
    assert_response :success

    get new_motivo_consulta_path
    assert_response :success

    get edit_motivo_consulta_path(@motivo_consulta)
    assert_response :success
  end

  test "crea un motivo de consulta con sus insumos requeridos" do
    assert_difference([ "MotivoConsulta.count", "InsumoRequerido.count" ], 1) do
      post motivos_consulta_path, params: { motivo_consulta: {
        nombre: "Apendicitis aguda", especialidad_id: especialidades(:cirugia).id,
        requiere_quirofano: "1", requiere_anestesista: "1", duracion_estimada_minutos: 90,
        insumos_requeridos_attributes: {
          "0" => { insumo_id: insumos(:sutura).id, cantidad: 2 },
          "1" => { insumo_id: "", cantidad: "" }
        }
      } }
    end

    motivo = MotivoConsulta.last
    assert_redirected_to motivo_consulta_path(motivo)
    assert motivo.requiere_quirofano
  end

  test "quita un insumo requerido existente" do
    insumo_requerido = insumos_requeridos(:herida_gasas)

    assert_difference("InsumoRequerido.count", -1) do
      patch motivo_consulta_path(@motivo_consulta), params: { motivo_consulta: {
        insumos_requeridos_attributes: { "0" => { id: insumo_requerido.id, _destroy: "1" } }
      } }
    end
  end

  test "elimina un motivo de consulta junto con sus insumos requeridos" do
    assert_difference([ "MotivoConsulta.count", "InsumoRequerido.count" ], -1) do
      delete motivo_consulta_path(@motivo_consulta)
    end
  end
end
