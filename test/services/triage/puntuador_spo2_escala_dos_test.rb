require "test_helper"

module Triage
  class PuntuadorSpo2EscalaDosTest < ActiveSupport::TestCase
    setup { @puntuador = PuntuadorSpo2EscalaDos.new }

    test "límites bajos, iguales con aire o con oxígeno: ≤83 → 3; 84–85 → 2; 86–87 → 1; 88–92 → 0" do
      { 50 => 3, 83 => 3, 84 => 2, 85 => 2, 86 => 1, 87 => 1, 88 => 0, 92 => 0 }.each do |spo2, puntaje|
        assert_equal puntaje, @puntuador.puntuar(spo2, con_oxigeno: false), "SpO2 #{spo2} con aire"
        assert_equal puntaje, @puntuador.puntuar(spo2, con_oxigeno: true), "SpO2 #{spo2} con oxígeno"
      end
    end

    test "con aire, una SpO2 de 93 o más vale 0" do
      [ 93, 95, 97, 100 ].each do |spo2|
        assert_equal 0, @puntuador.puntuar(spo2, con_oxigeno: false), "SpO2 #{spo2} con aire"
      end
    end

    test "con oxígeno: 93–94 → 1; 95–96 → 2; ≥97 → 3" do
      { 93 => 1, 94 => 1, 95 => 2, 96 => 2, 97 => 3, 100 => 3 }.each do |spo2, puntaje|
        assert_equal puntaje, @puntuador.puntuar(spo2, con_oxigeno: true), "SpO2 #{spo2} con oxígeno"
      end
    end
  end
end
