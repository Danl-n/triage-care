require "test_helper"

class ColaControllerTest < ActionDispatch::IntegrationTest
  include SignosDePrueba

  setup { sign_in_as users(:one) }

  def atencion_con_toma(paciente, signos)
    atencion = Atencion.create!(paciente: paciente, motivo_consulta: motivos_consulta(:herida),
                                hora_llegada: 20.minutes.ago)
    toma = atencion.tomas.new(signos.to_h.merge(registrada_por: users(:one)))
    Triage::ValoradorToma.new.valorar(toma).save!
    atencion
  end

  def nuevo_paciente
    Paciente.create!(cedula: "0918765439", nombres: "Ana María", apellidos: "Torres León",
                     fecha_nacimiento: Date.new(1992, 7, 2), sexo: "femenino", canton: cantones(:guayaquil))
  end

  test "exige iniciar sesión" do
    sign_out
    get cola_path

    assert_redirected_to new_session_path
  end

  test "ordena la cola por nivel de riesgo: Alto antes que Bajo-medio" do
    atencion_con_toma(pacientes(:jose), EJEMPLO_1) # Alto

    get cola_path

    assert_response :success
    assert_operator response.body.index("Zambrano Cedeño"), :<, response.body.index("Cevallos Mora"),
                    "José (Alto) debe aparecer antes que Valentina (Bajo-medio)"
  end

  test "muestra aparte las atenciones en espera que aún no tienen tomas" do
    Atencion.create!(paciente: nuevo_paciente, motivo_consulta: motivos_consulta(:herida), hora_llegada: 5.minutes.ago)

    get cola_path

    assert_match "Pendientes de primera toma (1)", response.body
    assert_match "Torres León", response.body
    assert_match "En espera (1)", response.body
  end

  test "solo incluye atenciones en espera" do
    atenciones(:valentina_en_espera).update!(estado: "en_atencion")

    get cola_path

    assert_no_match "Cevallos Mora", response.body
    assert_match "No hay pacientes valorados en espera", response.body
  end

  test "el panel enlaza a la cola priorizada" do
    get root_path

    assert_select "a[href=?]", cola_path
  end
end
