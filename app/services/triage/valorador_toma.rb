module Triage
  # Fachada (Facade) de la etapa 1: junta las piezas del core para valorar UNA toma.
  #   1. Elige la escala de SpO2 según la atención (fábrica) y calcula el NEWS2.
  #   2. Clasifica el riesgo y busca ese nivel (con sus tiempos configurables).
  #   3. Calcula la espera máxima, la próxima toma y la alerta de deterioro.
  # Deja el resultado en los atributos de la toma, pero NO la guarda: eso lo decide quien llama.
  class ValoradorToma
    AUMENTO_PARA_ALERTA = 2

    def initialize(clasificador: ClasificadorRiesgo.new)
      @clasificador = clasificador
    end

    def valorar(toma)
      atencion = toma.atencion
      resultado = calculadora_para(atencion).calcular(toma)
      nivel = NivelRiesgo.find_by!(nombre: @clasificador.clasificar(resultado))

      toma.assign_attributes(
        **puntajes_por_columna(resultado),
        puntaje_total: resultado.total,
        parametro_en_3: resultado.parametro_en_3?,
        nivel_riesgo: nivel,
        espera_maxima_hasta: atencion.hora_llegada + nivel.espera_maxima_minutos.minutes,
        proxima_toma: toma.tomada_en + nivel.frecuencia_toma_minutos.minutes,
        alerta_deterioro: deterioro?(toma.anterior, resultado.total)
      )
      toma
    end

    private
      def calculadora_para(atencion)
        CalculadoraNews2.new(puntuador_spo2: FabricaPuntuadorSpo2.para(escala_2: atencion.usa_escala_spo2_2))
      end

      # { frecuencia_respiratoria: 2, ... } → { puntaje_frecuencia_respiratoria: 2, ... }
      def puntajes_por_columna(resultado)
        resultado.puntajes.transform_keys { |parametro| :"puntaje_#{parametro}" }
      end

      def deterioro?(toma_anterior, total)
        return false if toma_anterior.nil?

        total - toma_anterior.puntaje_total >= AUMENTO_PARA_ALERTA
      end
  end
end
