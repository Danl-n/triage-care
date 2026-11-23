require "test_helper"

module Triage
  class PuntuadorSpo2EscalaUnoTest < ActiveSupport::TestCase
    setup { @puntuador = PuntuadorSpo2EscalaUno.new }

    test "límites de la escala 1: ≤91 → 3; 92–93 → 2; 94–95 → 1; ≥96 → 0" do
      { 50 => 3, 91 => 3, 92 => 2, 93 => 2, 94 => 1, 95 => 1, 96 => 0, 100 => 0 }.each do |spo2, puntaje|
        assert_equal puntaje, @puntuador.puntuar(spo2, con_oxigeno: false), "SpO2 #{spo2}"
      end
    end

    test "en la escala 1 el oxígeno no cambia el puntaje de la SpO2" do
      assert_equal 0, @puntuador.puntuar(97, con_oxigeno: true)
      assert_equal 3, @puntuador.puntuar(91, con_oxigeno: true)
    end
  end
end
