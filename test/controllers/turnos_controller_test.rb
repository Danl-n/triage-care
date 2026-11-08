require "test_helper"

class TurnosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @turno = turnos(:diurno)
    sign_in_as users(:one)
  end

  def datos_validos(**cambios)
    { especialidad_id: especialidades(:anestesiologia).id, medico_id: medicos(:vera).id,
      inicio: "2026-01-10T19:00", fin: "2026-01-11T07:00", modalidad: "de_llamada",
      tiempo_llegada_minutos: 30 }.merge(cambios)
  end

  test "lista, muestra y abre los formularios" do
    get turnos_path
    assert_response :success

    get turno_path(@turno)
    assert_response :success

    get new_turno_path
    assert_response :success

    get edit_turno_path(@turno)
    assert_response :success
  end

  test "crea un turno" do
    assert_difference("Turno.count") do
      post turnos_path, params: { turno: datos_validos }
    end

    assert_redirected_to turno_path(Turno.last)
  end

  test "el back-end rechaza un médico de otra especialidad aunque se manipule el formulario" do
    assert_no_difference("Turno.count") do
      post turnos_path, params: { turno: datos_validos(especialidad_id: especialidades(:cirugia).id) }
    end

    assert_response :unprocessable_content
    assert_match "no pertenece a la especialidad seleccionada", response.body
  end

  test "actualiza y elimina un turno" do
    patch turno_path(@turno), params: { turno: { fin: "2026-01-10T20:00" } }
    assert_redirected_to turno_path(@turno)

    assert_difference("Turno.count", -1) do
      delete turno_path(@turno)
    end
    assert_redirected_to turnos_path
  end
end
