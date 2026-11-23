require "test_helper"

module Triage
  class ClasificadorRiesgoTest < ActiveSupport::TestCase
    include SignosDePrueba

    setup { @clasificador = ClasificadorRiesgo.new }

    def resultado(**puntajes)
      ResultadoNews2.new(puntajes: puntajes)
    end

    test "total de 7 o más → Alto" do
      assert_equal "Alto", @clasificador.clasificar(resultado(a: 3, b: 3, c: 1))
      assert_equal "Alto", @clasificador.clasificar(resultado(a: 2, b: 2, c: 2, d: 1))
    end

    test "total de 5 a 6 → Medio" do
      assert_equal "Medio", @clasificador.clasificar(resultado(a: 2, b: 2, c: 2))
      assert_equal "Medio", @clasificador.clasificar(resultado(a: 2, b: 2, c: 1))
    end

    test "un total de 5 a 6 gana aunque haya un parámetro en 3 (vale la primera condición)" do
      assert_equal "Medio", @clasificador.clasificar(resultado(a: 3, b: 2))
    end

    test "total menor que 5 con algún parámetro en 3 → Bajo-medio" do
      assert_equal "Bajo-medio", @clasificador.clasificar(resultado(a: 3))
      assert_equal "Bajo-medio", @clasificador.clasificar(resultado(a: 3, b: 1))
    end

    test "cualquier otro caso → Bajo" do
      assert_equal "Bajo", @clasificador.clasificar(resultado(a: 0))
      assert_equal "Bajo", @clasificador.clasificar(resultado(a: 2, b: 2))
    end

    test "ejemplo 1 → Alto y ejemplo 2 → Bajo-medio" do
      calculadora = CalculadoraNews2.new(puntuador_spo2: PuntuadorSpo2EscalaUno.new)

      assert_equal "Alto", @clasificador.clasificar(calculadora.calcular(EJEMPLO_1))
      assert_equal "Bajo-medio", @clasificador.clasificar(calculadora.calcular(EJEMPLO_2))
    end
  end
end
