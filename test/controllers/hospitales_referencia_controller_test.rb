require "test_helper"

class HospitalesReferenciaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hospital_referencia = hospitales_referencia(:norte)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get hospitales_referencia_path
    assert_response :success

    get hospital_referencia_path(@hospital_referencia)
    assert_response :success

    get new_hospital_referencia_path
    assert_response :success

    get edit_hospital_referencia_path(@hospital_referencia)
    assert_response :success
  end

  test "crea, actualiza y elimina un hospital de referencia" do
    assert_difference("HospitalReferencia.count") do
      post hospitales_referencia_path, params: { hospital_referencia: {
        nombre: "Clínica Los Andes", tipo_red_id: tipos_red(:privada).id, telefono: "02 600 1000" } }
    end
    assert_redirected_to hospital_referencia_path(HospitalReferencia.last)

    patch hospital_referencia_path(@hospital_referencia), params: { hospital_referencia: { telefono: "(02) 255-0000" } }
    assert_redirected_to hospital_referencia_path(@hospital_referencia)

    assert_difference("HospitalReferencia.count", -1) do
      delete hospital_referencia_path(@hospital_referencia)
    end
  end
end
