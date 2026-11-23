module Triage
  # Ordena la cola de espera. Cada elemento debe responder a prioridad_riesgo (1 = Alto),
  # espera_maxima_hasta y hora_llegada. Criterios, en este orden:
  #   1. prioridad del nivel (Alto primero),
  #   2. minutos de espera excedida (de mayor a menor),
  #   3. hora de llegada (quien llegó antes, primero).
  # La hora actual se recibe en el constructor para que las pruebas no dependan del reloj.
  class PriorizadorCola
    def initialize(ahora: Time.current)
      @ahora = ahora
    end

    def ordenar(elementos)
      # sort_by compara los arreglos posición por posición. El signo menos invierte el
      # orden de los minutos excedidos para que el mayor quede primero.
      elementos.sort_by do |elemento|
        [ elemento.prioridad_riesgo, -minutos_excedidos(elemento), elemento.hora_llegada ]
      end
    end

    # Minutos completos que pasaron desde la espera máxima; 0 si todavía no vence.
    def minutos_excedidos(elemento)
      minutos = ((@ahora - elemento.espera_maxima_hasta) / 60).floor
      [ minutos, 0 ].max
    end
  end
end
