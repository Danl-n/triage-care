require "test_helper"

class PacientesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @paciente = pacientes(:jose)
    sign_in_as users(:one)
  end

  def datos_validos(**cambios)
    { cedula: "0918765439", nombres: "Ana María", apellidos: "Torres León", fecha_nacimiento: "1992-07-02",
      sexo: "femenino", provincia_id: provincias(:guayas).id, canton_id: cantones(:guayaquil).id }.merge(cambios)
  end

  test "lista, muestra y abre los formularios" do
    get pacientes_path
    assert_response :success

    get paciente_path(@paciente)
    assert_response :success

    get new_paciente_path
    assert_response :success

    get edit_paciente_path(@paciente)
    assert_response :success
  end

  test "crea un paciente con cédula válida" do
    assert_difference("Paciente.count") do
      post pacientes_path, params: { paciente: datos_validos }
    end

    assert_redirected_to paciente_path(Paciente.last)
  end

  test "rechaza una cédula inválida antes de guardar" do
    assert_no_difference("Paciente.count") do
      post pacientes_path, params: { paciente: datos_validos(cedula: "0918765430") }
    end

    assert_response :unprocessable_content
    assert_match "dígito verificador", response.body
  end

  test "el back-end rechaza un cantón de otra provincia aunque se manipule el formulario" do
    assert_no_difference("Paciente.count") do
      post pacientes_path, params: { paciente: datos_validos(provincia_id: provincias(:pichincha).id) }
    end

    assert_response :unprocessable_content
    assert_match "no pertenece a la provincia seleccionada", response.body
  end

  test "actualiza y elimina un paciente" do
    patch paciente_path(@paciente), params: { paciente: { nombres: "José" } }
    assert_redirected_to paciente_path(@paciente)

    assert_difference("Paciente.count", -1) do
      delete paciente_path(@paciente)
    end
    assert_redirected_to pacientes_path
  end
end
