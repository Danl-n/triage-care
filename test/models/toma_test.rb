require "test_helper"

class TomaTest < ActiveSupport::TestCase
  # campo => [mínimo, máximo, paso]: el paso es la unidad más pequeña que se puede registrar.
  RANGOS = {
    frecuencia_respiratoria: [ 0, 80, 1 ],
    spo2: [ 50, 100, 1 ],
    presion_sistolica: [ 40, 300, 1 ],
    pulso: [ 20, 250, 1 ],
    temperatura: [ 30.0, 45.0, 0.1 ]
  }.freeze

  def toma_valida(**cambios)
    Toma.new({ atencion: atenciones(:valentina_en_espera), registrada_por: users(:one),
               frecuencia_respiratoria: 18, spo2: 97, con_oxigeno: false, presion_sistolica: 120,
               pulso: 80, conciencia: "A", temperatura: 36.8 }.merge(cambios))
  end

  test "es válida con datos correctos" do
    assert toma_valida.valid?
  end

  test "la hora de la toma es, por defecto, el momento del registro" do
    assert_in_delta Time.current, toma_valida.tomada_en, 5.seconds
  end

  RANGOS.each do |campo, (minimo, maximo, paso)|
    test "#{campo} acepta valores de #{minimo} a #{maximo}, ambos incluidos" do
      assert toma_valida(campo => minimo).valid?
      assert toma_valida(campo => maximo).valid?
      assert_not toma_valida(campo => minimo - paso).valid?
      assert_not toma_valida(campo => maximo + paso).valid?
    end

    test "#{campo} es obligatorio" do
      assert_not toma_valida(campo => nil).valid?
    end
  end

  test "los signos enteros no aceptan decimales" do
    assert_not toma_valida(frecuencia_respiratoria: 18.5).valid?
    assert_not toma_valida(pulso: 80.2).valid?
  end

  test "la temperatura se guarda con un decimal" do
    assert_equal BigDecimal("36.9"), toma_valida(temperatura: 36.86).temperatura
  end

  test "la conciencia solo acepta A, C, V, P o U" do
    %w[ A C V P U ].each { |nivel| assert toma_valida(conciencia: nivel).valid? }

    toma = toma_valida(conciencia: "X")
    assert_not toma.valid?
    assert toma.errors.key?(:conciencia)
  end

  test "con_oxigeno debe ser verdadero o falso" do
    assert_not toma_valida(con_oxigeno: nil).valid?
  end

  test "una atención finalizada o derivada no admite tomas" do
    atencion = atenciones(:valentina_en_espera)

    %w[ finalizada derivada ].each do |estado|
      atencion.update!(estado: estado)
      toma = toma_valida(atencion: atencion)

      assert_not toma.valid?
      assert_includes toma.errors.details[:base], { error: :atencion_cerrada }
    end
  end

  test "la base de datos también rechaza valores fuera de rango" do
    toma = toma_valida(spo2: 120)

    assert_raises(ActiveRecord::StatementInvalid) { toma.save(validate: false) }
  end

  test "una atención con tomas no se puede eliminar" do
    assert_not atenciones(:valentina_en_espera).destroy
  end
end
