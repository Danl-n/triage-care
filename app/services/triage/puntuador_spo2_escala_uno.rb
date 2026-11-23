module Triage
  # Estrategia de SpO2 por defecto (escala 1 de NEWS2).
  # Recibe con_oxigeno aunque no lo use para tener la misma interfaz que la escala 2:
  # así la calculadora puede usar cualquiera de las dos sin saber cuál es (Liskov).
  class PuntuadorSpo2EscalaUno
    def puntuar(spo2, con_oxigeno:)
      case spo2
      when ..91 then 3
      when ..93 then 2
      when ..95 then 1
      else 0
      end
    end
  end
end
