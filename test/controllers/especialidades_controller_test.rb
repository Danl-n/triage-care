require "test_helper"

class EspecialidadesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @especialidad = especialidades(:anestesiologia)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get especialidades_path
    assert_response :success

    get especialidad_path(@especialidad)
    assert_response :success

    get new_especialidad_path
    assert_response :success

    get edit_especialidad_path(@especialidad)
    assert_response :success
  end

  test "crea y actualiza una especialidad" do
    assert_difference("Especialidad.count") do
      post especialidades_path, params: { especialidad: { nombre: "Pediatría" } }
    end
    assert_redirected_to especialidad_path(Especialidad.last)

    patch especialidad_path(@especialidad), params: { especialidad: { nombre: "Anestesia" } }
    assert_redirected_to especialidad_path(@especialidad)
  end

  test "no elimina una especialidad con médicos" do
    assert_no_difference("Especialidad.count") do
      delete especialidad_path(@especialidad)
    end
  end

  test "devuelve en JSON los médicos de la especialidad (dropdown dependiente)" do
    get medicos_especialidad_path(@especialidad), as: :json

    assert_response :success
    assert_equal [ { "id" => medicos(:vera).id, "nombre" => "Vera Lucía" } ], response.parsed_body
  end
end
