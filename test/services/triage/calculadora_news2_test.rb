require "test_helper"

module Triage
  class CalculadoraNews2Test < ActiveSupport::TestCase
    include SignosDePrueba

    setup { @calculadora = CalculadoraNews2.new(puntuador_spo2: PuntuadorSpo2EscalaUno.new) }

    def assert_puntajes(parametro, valores_y_puntajes)
      valores_y_puntajes.each do |valor, esperado|
        resultado = @calculadora.calcular(NORMALES.with(parametro => valor))

        assert_equal esperado, resultado.puntajes.fetch(parametro), "#{parametro} = #{valor}"
      end
    end

    test "signos normales suman 0" do
      resultado = @calculadora.calcular(NORMALES)

      assert_equal 0, resultado.total
      assert_not resultado.parametro_en_3?
    end

    test "frecuencia respiratoria: ≤8 → 3; 9–11 → 1; 12–20 → 0; 21–24 → 2; ≥25 → 3" do
      assert_puntajes :frecuencia_respiratoria,
                      0 => 3, 8 => 3, 9 => 1, 11 => 1, 12 => 0, 20 => 0, 21 => 2, 24 => 2, 25 => 3, 80 => 3
    end

    test "SpO2 con la escala inyectada (escala 1)" do
      assert_puntajes :spo2, 91 => 3, 92 => 2, 94 => 1, 96 => 0
    end

    test "oxígeno suplementario: aire → 0; oxígeno → 2" do
      assert_puntajes :con_oxigeno, false => 0, true => 2
    end

    test "presión sistólica: ≤90 → 3; 91–100 → 2; 101–110 → 1; 111–219 → 0; ≥220 → 3" do
      assert_puntajes :presion_sistolica,
                      40 => 3, 90 => 3, 91 => 2, 100 => 2, 101 => 1, 110 => 1, 111 => 0, 219 => 0, 220 => 3, 300 => 3
    end

    test "pulso: ≤40 → 3; 41–50 → 1; 51–90 → 0; 91–110 → 1; 111–130 → 2; ≥131 → 3" do
      assert_puntajes :pulso,
                      20 => 3, 40 => 3, 41 => 1, 50 => 1, 51 => 0, 90 => 0, 91 => 1, 110 => 1, 111 => 2, 130 => 2, 131 => 3
    end

    test "conciencia: A → 0; C, V, P o U → 3" do
      assert_puntajes :conciencia, "A" => 0, "C" => 3, "V" => 3, "P" => 3, "U" => 3
    end

    test "temperatura: ≤35,0 → 3; 35,1–36,0 → 1; 36,1–38,0 → 0; 38,1–39,0 → 1; ≥39,1 → 2" do
      assert_puntajes :temperatura,
                      30.0 => 3, 35.0 => 3, 35.1 => 1, 36.0 => 1, 36.1 => 0, 38.0 => 0, 38.1 => 1, 39.0 => 1, 39.1 => 2, 45.0 => 2
    end

    test "acepta la temperatura como BigDecimal, que es como llega desde la base de datos" do
      assert_puntajes :temperatura, BigDecimal("35.0") => 3, BigDecimal("35.1") => 1
    end

    test "delega la SpO2 en el puntuador que recibe (inversión de dependencias)" do
      puntuador_falso = Object.new
      def puntuador_falso.puntuar(_spo2, con_oxigeno:) = 3

      resultado = CalculadoraNews2.new(puntuador_spo2: puntuador_falso).calcular(NORMALES)

      assert_equal 3, resultado.puntajes[:spo2]
    end

    test "ejemplo 1: FR 23, SpO2 94, aire, PAS 105, pulso 112, A, 38,4 °C → total 7" do
      resultado = @calculadora.calcular(EJEMPLO_1)

      assert_equal({ frecuencia_respiratoria: 2, spo2: 1, con_oxigeno: 0, presion_sistolica: 1,
                     pulso: 2, conciencia: 0, temperatura: 1 }, resultado.puntajes)
      assert_equal 7, resultado.total
      assert_not resultado.parametro_en_3?
    end

    test "ejemplo 2: FR 18, SpO2 97, aire, PAS 88, pulso 80, A, 36,8 °C → total 3 con la PAS en 3" do
      resultado = @calculadora.calcular(EJEMPLO_2)

      assert_equal 3, resultado.puntajes[:presion_sistolica]
      assert_equal 3, resultado.total
      assert resultado.parametro_en_3?
    end
  end
end
