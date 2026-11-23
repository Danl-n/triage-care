module Triage
  # Estrategia de SpO2 para pacientes con insuficiencia respiratoria hipercápnica (escala 2 de NEWS2).
  # Su meta es 88–92 %: por encima de eso, con oxígeno, una SpO2 alta también suma puntos.
  class PuntuadorSpo2EscalaDos
    def puntuar(spo2, con_oxigeno:)
      case spo2
      when ..83 then 3
      when ..85 then 2
      when ..87 then 1
      when ..92 then 0
      else con_oxigeno ? puntuar_alta_con_oxigeno(spo2) : 0
      end
    end

    private
      # Solo para SpO2 de 93 o más con oxígeno suplementario.
      def puntuar_alta_con_oxigeno(spo2)
        case spo2
        when ..94 then 1
        when ..96 then 2
        else 3
        end
      end
  end
end
