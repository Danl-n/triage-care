module Triage
  # Decide el nivel de riesgo a partir de un ResultadoNews2. Revisa las condiciones en orden
  # y se queda con la primera que se cumple. Devuelve el NOMBRE del nivel, que coincide con
  # el de los 4 niveles cargados por seed: así esta clase no necesita la base de datos.
  class ClasificadorRiesgo
    ALTO = "Alto"
    MEDIO = "Medio"
    BAJO_MEDIO = "Bajo-medio"
    BAJO = "Bajo"

    TOTAL_MINIMO_ALTO = 7
    TOTAL_MINIMO_MEDIO = 5

    def clasificar(resultado)
      if resultado.total >= TOTAL_MINIMO_ALTO
        ALTO
      elsif resultado.total >= TOTAL_MINIMO_MEDIO
        MEDIO
      elsif resultado.parametro_en_3?
        BAJO_MEDIO
      else
        BAJO
      end
    end
  end
end
