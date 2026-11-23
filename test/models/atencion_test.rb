require "test_helper"

class AtencionTest < ActiveSupport::TestCase
  def atencion_valida(**cambios)
    Atencion.new({ paciente: pacientes(:jose), motivo_consulta: motivos_consulta(:herida),
                   hora_llegada: 10.minutes.ago }.merge(cambios))
  end

  test "es válida con datos correctos y empieza en espera" do
    atencion = atencion_valida

    assert atencion.valid?
    assert atencion.en_espera?
    assert_not atencion.usa_escala_spo2_2?
  end

  test "un paciente no puede tener dos atenciones abiertas" do
    atencion = atencion_valida(paciente: pacientes(:valentina))

    assert_not atencion.valid?
    assert_includes atencion.errors.details[:paciente], { error: :atencion_abierta }
  end

  test "también cuenta como abierta una atención en atención" do
    atenciones(:valentina_en_espera).update!(estado: "en_atencion")

    assert_not atencion_valida(paciente: pacientes(:valentina)).valid?
  end

  test "permite una nueva atención cuando la anterior ya está cerrada" do
    atenciones(:valentina_en_espera).update!(estado: "finalizada")

    assert atencion_valida(paciente: pacientes(:valentina)).valid?
  end

  test "la base de datos también impide dos atenciones abiertas del mismo paciente" do
    duplicada = atencion_valida(paciente: pacientes(:valentina))

    assert_raises(ActiveRecord::RecordNotUnique) { duplicada.save(validate: false) }
  end

  test "la hora de llegada es obligatoria y no puede ser futura" do
    assert_not atencion_valida(hora_llegada: nil).valid?

    atencion = atencion_valida(hora_llegada: 1.hour.from_now)
    assert_not atencion.valid?
    assert_includes atencion.errors.details[:hora_llegada], { error: :no_futura }
  end

  test "solo acepta los estados definidos" do
    atencion = atencion_valida(estado: "perdida")

    assert_not atencion.valid?
    assert atencion.errors.key?(:estado)
  end

  test "abierta? distingue los estados abiertos de los cerrados" do
    assert atencion_valida(estado: "en_espera").abierta?
    assert atencion_valida(estado: "en_atencion").abierta?
    assert_not atencion_valida(estado: "finalizada").abierta?
    assert_not atencion_valida(estado: "derivada").abierta?
  end

  test "no se puede eliminar un paciente ni un motivo de consulta con atenciones" do
    assert_not pacientes(:valentina).destroy
    assert_not motivos_consulta(:fiebre).destroy
  end
end
