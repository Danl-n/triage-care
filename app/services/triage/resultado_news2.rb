module Triage
  # Resultado inmutable de un cálculo NEWS2: el puntaje de cada parámetro y lo que se deduce de él.
  # Data.define crea una clase de valor: se construye con new(puntajes: {...}) y no se puede modificar.
  ResultadoNews2 = Data.define(:puntajes) do
    def total
      puntajes.values.sum
    end

    def parametro_en_3?
      puntajes.value?(3)
    end
  end
end
