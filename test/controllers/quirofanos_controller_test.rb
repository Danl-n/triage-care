require "test_helper"

class QuirofanosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quirofano = quirofanos(:uno)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get quirofanos_path
    assert_response :success

    get quirofano_path(@quirofano)
    assert_response :success

    get new_quirofano_path
    assert_response :success

    get edit_quirofano_path(@quirofano)
    assert_response :success
  end

  test "crea, actualiza y elimina un quirófano" do
    assert_difference("Quirofano.count") do
      post quirofanos_path, params: { quirofano: { nombre: "Quirófano 2", estado: "mantenimiento" } }
    end
    assert_redirected_to quirofano_path(Quirofano.last)

    patch quirofano_path(@quirofano), params: { quirofano: { estado: "ocupado" } }
    assert_equal "ocupado", @quirofano.reload.estado

    assert_difference("Quirofano.count", -1) do
      delete quirofano_path(@quirofano)
    end
  end

  test "rechaza un estado que no existe" do
    post quirofanos_path, params: { quirofano: { nombre: "Quirófano 9", estado: "roto" } }

    assert_response :unprocessable_content
  end
end
