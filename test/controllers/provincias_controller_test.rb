require "test_helper"

class ProvinciasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provincia = provincias(:pichincha)
    sign_in_as users(:one)
  end

  test "exige iniciar sesión" do
    sign_out
    get provincias_path

    assert_redirected_to new_session_path
  end

  test "lista, muestra y abre los formularios" do
    get provincias_path
    assert_response :success

    get provincia_path(@provincia)
    assert_response :success

    get new_provincia_path
    assert_response :success

    get edit_provincia_path(@provincia)
    assert_response :success
  end

  test "crea una provincia" do
    assert_difference("Provincia.count") do
      post provincias_path, params: { provincia: { codigo: "18", nombre: "Tungurahua" } }
    end

    assert_redirected_to provincia_path(Provincia.last)
  end

  test "muestra los errores si los datos no son válidos" do
    assert_no_difference("Provincia.count") do
      post provincias_path, params: { provincia: { codigo: "99", nombre: "" } }
    end

    assert_response :unprocessable_content
  end

  test "actualiza una provincia" do
    patch provincia_path(@provincia), params: { provincia: { nombre: "Pichincha (editada)" } }

    assert_redirected_to provincia_path(@provincia)
    assert_equal "Pichincha (editada)", @provincia.reload.nombre
  end

  test "no elimina una provincia con cantones" do
    assert_no_difference("Provincia.count") do
      delete provincia_path(@provincia)
    end

    assert_redirected_to provincia_path(@provincia)
  end

  test "devuelve en JSON los cantones de la provincia (dropdown dependiente)" do
    get cantones_provincia_path(@provincia), as: :json

    assert_response :success
    assert_equal [ { "id" => cantones(:quito).id, "nombre" => "Quito" } ], response.parsed_body
  end
end
