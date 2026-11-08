require "test_helper"

class MedicosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @medico = medicos(:vera)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get medicos_path
    assert_response :success

    get medico_path(@medico)
    assert_response :success

    get new_medico_path
    assert_response :success

    get edit_medico_path(@medico)
    assert_response :success
  end

  test "crea un médico (el validador de cédula se reutiliza aquí)" do
    assert_difference("Medico.count") do
      post medicos_path, params: { medico: { cedula: "1709876542", nombres: "Carlos", apellidos: "Mendoza",
                                             especialidad_id: especialidades(:cirugia).id } }
    end
    assert_redirected_to medico_path(Medico.last)

    assert_no_difference("Medico.count") do
      post medicos_path, params: { medico: { cedula: "1709876540", nombres: "X", apellidos: "Y",
                                             especialidad_id: especialidades(:cirugia).id } }
    end
    assert_response :unprocessable_content
  end

  test "actualiza un médico y no lo elimina si tiene turnos" do
    patch medico_path(@medico), params: { medico: { nombres: "Lucía Fernanda" } }
    assert_redirected_to medico_path(@medico)

    assert_no_difference("Medico.count") do
      delete medico_path(medicos(:paredes))
    end
  end
end
