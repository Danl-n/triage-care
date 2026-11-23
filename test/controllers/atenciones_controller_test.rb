require "test_helper"

class AtencionesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @atencion = atenciones(:valentina_en_espera)
    sign_in_as users(:one)
  end

  def datos_validos(**cambios)
    { paciente_id: pacientes(:jose).id, motivo_consulta_id: motivos_consulta(:herida).id,
      hora_llegada: 5.minutes.ago.change(sec: 0), estado: "en_espera" }.merge(cambios)
  end

  test "exige iniciar sesión" do
    sign_out
    get atenciones_path

    assert_redirected_to new_session_path
  end

  test "lista, muestra y abre los formularios" do
    get atenciones_path
    assert_response :success

    get atencion_path(@atencion)
    assert_response :success

    get new_atencion_path
    assert_response :success

    get edit_atencion_path(@atencion)
    assert_response :success
  end

  test "registra una atención" do
    assert_difference("Atencion.count") do
      post atenciones_path, params: { atencion: datos_validos }
    end

    assert_redirected_to atencion_path(Atencion.last)
  end

  test "rechaza una segunda atención abierta del mismo paciente" do
    assert_no_difference("Atencion.count") do
      post atenciones_path, params: { atencion: datos_validos(paciente_id: pacientes(:valentina).id) }
    end

    assert_response :unprocessable_content
    assert_match "ya tiene una atención abierta", response.body
  end

  test "ignora usa_escala_spo2_2 si llega desde el formulario" do
    post atenciones_path, params: { atencion: datos_validos(usa_escala_spo2_2: "1") }

    assert_not Atencion.last.usa_escala_spo2_2?
  end

  test "actualiza el estado de una atención" do
    patch atencion_path(@atencion), params: { atencion: { estado: "finalizada" } }

    assert_redirected_to atencion_path(@atencion)
    assert @atencion.reload.finalizada?
  end

  test "elimina una atención" do
    assert_difference("Atencion.count", -1) do
      delete atencion_path(@atencion)
    end

    assert_redirected_to atenciones_path
  end

  test "no elimina un paciente con atenciones y muestra el motivo" do
    assert_no_difference("Paciente.count") do
      delete paciente_path(pacientes(:valentina))
    end

    assert_redirected_to paciente_path(pacientes(:valentina))
    follow_redirect!
    assert_match "atenciones", response.body
  end
end
