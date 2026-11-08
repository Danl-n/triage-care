require "test_helper"

class NivelesRiesgoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @nivel_riesgo = niveles_riesgo(:alto)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre el formulario de edición" do
    get niveles_riesgo_path
    assert_response :success

    get nivel_riesgo_path(@nivel_riesgo)
    assert_response :success

    get edit_nivel_riesgo_path(@nivel_riesgo)
    assert_response :success
  end

  test "solo actualiza los tiempos: nombre, prioridad y criterio no se pueden cambiar" do
    patch nivel_riesgo_path(@nivel_riesgo), params: { nivel_riesgo: {
      espera_maxima_minutos: 5, frecuencia_toma_minutos: 10, limite_derivacion_minutos: 20,
      nombre: "Crítico", prioridad: 9, criterio: "otro"
    } }

    @nivel_riesgo.reload
    assert_redirected_to nivel_riesgo_path(@nivel_riesgo)
    assert_equal [ 5, 10, 20 ], [ @nivel_riesgo.espera_maxima_minutos, @nivel_riesgo.frecuencia_toma_minutos,
                                  @nivel_riesgo.limite_derivacion_minutos ]
    assert_equal [ "Alto", 1 ], [ @nivel_riesgo.nombre, @nivel_riesgo.prioridad ]
  end

  test "no existen rutas para crear ni eliminar niveles" do
    assert_not respond_to?(:new_nivel_riesgo_path)

    assert_no_difference("NivelRiesgo.count") do
      delete nivel_riesgo_path(@nivel_riesgo)
    end
    assert_response :not_found
  end

  test "rechaza tiempos inválidos" do
    patch nivel_riesgo_path(@nivel_riesgo), params: { nivel_riesgo: { frecuencia_toma_minutos: 0 } }

    assert_response :unprocessable_content
  end
end
