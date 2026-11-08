require "test_helper"

class TurnoTest < ActiveSupport::TestCase
  def turno_valido(**cambios)
    Turno.new({ especialidad_id: especialidades(:anestesiologia).id, medico: medicos(:vera),
                inicio: Time.zone.local(2026, 1, 10, 19), fin: Time.zone.local(2026, 1, 11, 7),
                modalidad: "de_llamada", tiempo_llegada_minutos: 30 }.merge(cambios))
  end

  test "es válido con datos correctos" do
    assert turno_valido.valid?
  end

  test "rechaza un médico que no pertenece a la especialidad elegida" do
    turno = turno_valido(especialidad_id: especialidades(:cirugia).id)

    assert_not turno.valid?
    assert_includes turno.errors.details[:medico], { error: :no_pertenece_a_especialidad }
  end

  test "el fin debe ser posterior al inicio" do
    turno = turno_valido(fin: Time.zone.local(2026, 1, 10, 18))

    assert_not turno.valid?
    assert_includes turno.errors.details[:fin], { error: :posterior_al_inicio }
  end

  test "si está de llamada necesita un tiempo de llegada mayor que 0" do
    turno = turno_valido(tiempo_llegada_minutos: 0)

    assert_not turno.valid?
    assert_includes turno.errors.details[:tiempo_llegada_minutos], { error: :requerido_si_de_llamada }
  end

  test "si es presencial el tiempo de llegada debe ser 0" do
    turno = turno_valido(modalidad: "presencial", tiempo_llegada_minutos: 15)

    assert_not turno.valid?
    assert_includes turno.errors.details[:tiempo_llegada_minutos], { error: :debe_ser_cero_si_presencial }
  end

  test "no permite turnos cruzados del mismo médico" do
    existente = turnos(:diurno)
    turno = turno_valido(especialidad_id: existente.medico.especialidad_id, medico: existente.medico,
                         inicio: existente.inicio + 2.hours, fin: existente.fin + 2.hours,
                         modalidad: "presencial", tiempo_llegada_minutos: 0)

    assert_not turno.valid?
    assert_includes turno.errors.details[:base], { error: :turno_cruzado }
  end
end
