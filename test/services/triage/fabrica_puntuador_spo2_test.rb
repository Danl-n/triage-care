require "test_helper"

module Triage
  class FabricaPuntuadorSpo2Test < ActiveSupport::TestCase
    test "entrega la escala 1 por defecto" do
      assert_instance_of PuntuadorSpo2EscalaUno, FabricaPuntuadorSpo2.para(escala_2: false)
    end

    test "entrega la escala 2 cuando la atención la usa" do
      assert_instance_of PuntuadorSpo2EscalaDos, FabricaPuntuadorSpo2.para(escala_2: true)
    end
  end
end
