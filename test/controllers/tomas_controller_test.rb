require "test_helper"

class TomasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @atencion = atenciones(:valentina_en_espera)
    sign_in_as users(:one)
  end

  # Signos del ejemplo 1 del enunciado: NEWS2 = 7 → Alto.
  def signos_ejemplo_1(**cambios)
    { frecuencia_respiratoria: 23, spo2: 94, con_oxigeno: "0", presion_sistolica: 105,
      pulso: 112, conciencia: "A", temperatura: "38.4" }.merge(cambios)
  end

  test "exige iniciar sesión" do
    sign_out
    get new_atencion_toma_path(@atencion)

    assert_redirected_to new_session_path
  end

  test "muestra el formulario de toma" do
    get new_atencion_toma_path(@atencion)

    assert_response :success
  end

  test "registra la toma, calcula el resultado y lo muestra" do
    assert_difference("Toma.count") do
      post atencion_tomas_path(@atencion), params: { toma: signos_ejemplo_1 }
    end

    toma = Toma.last
    assert_redirected_to atencion_toma_path(@atencion, toma)
    assert_equal 7, toma.puntaje_total
    assert_equal niveles_riesgo(:alto), toma.nivel_riesgo
    assert_equal users(:one), toma.registrada_por
    assert toma.alerta_deterioro, "sube de 3 (toma anterior) a 7"

    follow_redirect!
    assert_match "Alto", response.body
    assert_match "Alerta de deterioro", response.body
  end

  test "rechaza signos fuera de rango sin guardar nada" do
    assert_no_difference("Toma.count") do
      post atencion_tomas_path(@atencion), params: { toma: signos_ejemplo_1(spo2: 120) }
    end

    assert_response :unprocessable_content
  end

  test "una atención finalizada no admite tomas" do
    @atencion.update!(estado: "finalizada")

    assert_no_difference("Toma.count") do
      post atencion_tomas_path(@atencion), params: { toma: signos_ejemplo_1 }
    end

    assert_response :unprocessable_content
    assert_match "no admite nuevas tomas", response.body
  end

  test "el detalle de la atención muestra el historial de tomas" do
    get atencion_path(@atencion)

    assert_response :success
    assert_match "Bajo-medio", response.body
    assert_match "Nueva toma de signos", response.body
  end
end
