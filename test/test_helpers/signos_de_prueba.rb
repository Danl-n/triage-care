# Signos vitales de prueba para los servicios del core. Son objetos Data (inmutables) y no
# registros de la base de datos: a los servicios solo les importa que respondan a estos
# 7 métodos (duck typing).
module SignosDePrueba
  Signos = Data.define(:frecuencia_respiratoria, :spo2, :con_oxigeno, :presion_sistolica,
                       :pulso, :conciencia, :temperatura)

  # Suman 0 en todos los parámetros: cada prueba de límites cambia solo uno con `with`.
  NORMALES = Signos.new(frecuencia_respiratoria: 16, spo2: 97, con_oxigeno: false, presion_sistolica: 120,
                        pulso: 70, conciencia: "A", temperatura: 37.0)

  # Ejemplos del enunciado.
  EJEMPLO_1 = Signos.new(frecuencia_respiratoria: 23, spo2: 94, con_oxigeno: false, presion_sistolica: 105,
                         pulso: 112, conciencia: "A", temperatura: 38.4)

  EJEMPLO_2 = Signos.new(frecuencia_respiratoria: 18, spo2: 97, con_oxigeno: false, presion_sistolica: 88,
                         pulso: 80, conciencia: "A", temperatura: 36.8)
end
