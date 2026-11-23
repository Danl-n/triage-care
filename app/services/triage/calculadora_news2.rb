module Triage
  # Calcula el puntaje NEWS2 a partir de los signos vitales.
  #
  # `signos` puede ser cualquier objeto que responda a frecuencia_respiratoria, spo2, con_oxigeno,
  # presion_sistolica, pulso, conciencia y temperatura (en la app es una Toma). La escala de SpO2
  # llega desde afuera (inyección de dependencias), así la calculadora no decide cuál usar.
  #
  # En cada `case`, cada `when ..n` es el límite superior INCLUSIVO del tramo; como se evalúan
  # en orden, el límite inferior es el tramo anterior. Así no quedan huecos entre tramos.
  class CalculadoraNews2
    PUNTAJE_OXIGENO = 2
    CONCIENCIA_ALERTA = "A"

    def initialize(puntuador_spo2:)
      @puntuador_spo2 = puntuador_spo2
    end

    def calcular(signos)
      ResultadoNews2.new(puntajes: {
        frecuencia_respiratoria: puntuar_frecuencia_respiratoria(signos.frecuencia_respiratoria),
        spo2: @puntuador_spo2.puntuar(signos.spo2, con_oxigeno: signos.con_oxigeno),
        con_oxigeno: signos.con_oxigeno ? PUNTAJE_OXIGENO : 0,
        presion_sistolica: puntuar_presion_sistolica(signos.presion_sistolica),
        pulso: puntuar_pulso(signos.pulso),
        conciencia: signos.conciencia == CONCIENCIA_ALERTA ? 0 : 3,
        temperatura: puntuar_temperatura(signos.temperatura)
      })
    end

    private
      def puntuar_frecuencia_respiratoria(frecuencia)
        case frecuencia
        when ..8 then 3
        when ..11 then 1
        when ..20 then 0
        when ..24 then 2
        else 3
        end
      end

      def puntuar_presion_sistolica(presion)
        case presion
        when ..90 then 3
        when ..100 then 2
        when ..110 then 1
        when ..219 then 0
        else 3
        end
      end

      def puntuar_pulso(pulso)
        case pulso
        when ..40 then 3
        when ..50 then 1
        when ..90 then 0
        when ..110 then 1
        when ..130 then 2
        else 3
        end
      end

      def puntuar_temperatura(temperatura)
        case temperatura
        when ..35.0 then 3
        when ..36.0 then 1
        when ..38.0 then 0
        when ..39.0 then 1
        else 2
        end
      end
  end
end
