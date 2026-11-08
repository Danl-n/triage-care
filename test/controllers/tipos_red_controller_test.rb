require "test_helper"

class TiposRedControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tipo_red = tipos_red(:privada)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get tipos_red_path
    assert_response :success

    get tipo_red_path(@tipo_red)
    assert_response :success

    get new_tipo_red_path
    assert_response :success

    get edit_tipo_red_path(@tipo_red)
    assert_response :success
  end

  test "crea, actualiza y elimina un tipo de red" do
    assert_difference("TipoRed.count") do
      post tipos_red_path, params: { tipo_red: { nombre: "Red de prueba", descripcion: "Ejemplo" } }
    end
    assert_redirected_to tipo_red_path(TipoRed.last)

    patch tipo_red_path(@tipo_red), params: { tipo_red: { descripcion: "Clínicas privadas" } }
    assert_redirected_to tipo_red_path(@tipo_red)

    assert_difference("TipoRed.count", -1) do
      delete tipo_red_path(@tipo_red)
    end
  end

  test "no elimina un tipo de red con hospitales" do
    assert_no_difference("TipoRed.count") do
      delete tipo_red_path(tipos_red(:publica))
    end
  end
end
