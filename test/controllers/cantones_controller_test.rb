require "test_helper"

class CantonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @canton = cantones(:guayaquil)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get cantones_path
    assert_response :success

    get canton_path(@canton)
    assert_response :success

    get new_canton_path
    assert_response :success

    get edit_canton_path(@canton)
    assert_response :success
  end

  test "crea un cantón eligiendo la provincia del dropdown" do
    assert_difference("Canton.count") do
      post cantones_path, params: { canton: { nombre: "Cayambe", provincia_id: provincias(:pichincha).id } }
    end

    assert_redirected_to canton_path(Canton.last)
  end

  test "actualiza y elimina un cantón sin pacientes" do
    patch canton_path(@canton), params: { canton: { nombre: "Guayaquil (editado)" } }
    assert_redirected_to canton_path(@canton)

    assert_difference("Canton.count", -1) do
      delete canton_path(@canton)
    end
    assert_redirected_to cantones_path
  end
end
