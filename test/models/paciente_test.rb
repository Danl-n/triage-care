require "test_helper"

class PacienteTest < ActiveSupport::TestCase
  def paciente_valido(**cambios)
    Paciente.new({ cedula: "0918765439", nombres: "Ana María", apellidos: "Torres León",
                   fecha_nacimiento: Date.new(1992, 7, 2), sexo: "femenino",
                   provincia_id: provincias(:guayas).id, canton: cantones(:guayaquil) }.merge(cambios))
  end

  test "es válido con datos correctos" do
    assert paciente_valido.valid?
  end

  test "valida la cédula con el validador propio antes de guardar" do
    paciente = paciente_valido(cedula: "0918765430")

    assert_not paciente.save
    assert_includes paciente.errors.details[:cedula], { error: :cedula_verificador }
  end

  test "no permite cédulas duplicadas" do
    paciente = paciente_valido(cedula: pacientes(:jose).cedula)

    assert_not paciente.valid?
    assert_includes paciente.errors.details[:cedula].map { |d| d[:error] }, :taken
  end

  test "la base de datos también rechaza cédulas duplicadas" do
    duplicado = paciente_valido(cedula: pacientes(:jose).cedula)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicado.save(validate: false) }
  end

  test "rechaza un cantón que no pertenece a la provincia elegida" do
    paciente = paciente_valido(provincia_id: provincias(:pichincha).id, canton: cantones(:guayaquil))

    assert_not paciente.valid?
    assert_includes paciente.errors.details[:canton], { error: :no_pertenece_a_provincia }
  end

  test "deduce la provincia a partir del cantón cuando no se envía" do
    assert_equal provincias(:pichincha).id, pacientes(:jose).provincia_id
  end

  test "no acepta fechas de nacimiento futuras" do
    paciente = paciente_valido(fecha_nacimiento: Date.current + 1)

    assert_not paciente.valid?
    assert_includes paciente.errors.details[:fecha_nacimiento], { error: :no_futura }
  end

  test "solo acepta los sexos definidos" do
    paciente = paciente_valido(sexo: "otro")

    assert_not paciente.valid?
    assert paciente.errors.key?(:sexo)
  end
end
