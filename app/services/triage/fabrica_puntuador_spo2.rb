module Triage
  # Factory: es el único lugar que sabe qué estrategia de SpO2 corresponde a cada caso.
  # Si mañana aparece una tercera escala, se agrega aquí y la calculadora no cambia.
  class FabricaPuntuadorSpo2
    def self.para(escala_2:)
      escala_2 ? PuntuadorSpo2EscalaDos.new : PuntuadorSpo2EscalaUno.new
    end
  end
end
