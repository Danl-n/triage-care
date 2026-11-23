require "test_helper"

module Triage
  class PriorizadorColaTest < ActiveSupport::TestCase
    # Doble de prueba: el priorizador solo necesita estos 3 datos de cada elemento de la cola.
    Elemento = Data.define(:nombre, :prioridad_riesgo, :espera_maxima_hasta, :hora_llegada)

    AHORA = Time.zone.local(2026, 11, 23, 12, 0)

    setup { @priorizador = PriorizadorCola.new(ahora: AHORA) }

    # excedido: minutos que ya pasaron desde la espera máxima (negativo = todavía no vence).
    def elemento(nombre, prioridad:, excedido: 0, llegada: AHORA - 1.hour)
      Elemento.new(nombre: nombre, prioridad_riesgo: prioridad,
                   espera_maxima_hasta: AHORA - excedido.minutes, hora_llegada: llegada)
    end

    def nombres_ordenados(*elementos)
      @priorizador.ordenar(elementos).map(&:nombre)
    end

    test "primero ordena por la prioridad del nivel (Alto = 1 va primero)" do
      assert_equal %w[ alto medio bajo ],
                   nombres_ordenados(elemento("bajo", prioridad: 4), elemento("alto", prioridad: 1),
                                     elemento("medio", prioridad: 2))
    end

    test "la prioridad pesa más que la espera excedida" do
      assert_equal %w[ medio bajo ],
                   nombres_ordenados(elemento("bajo", prioridad: 4, excedido: 100), elemento("medio", prioridad: 2))
    end

    test "con la misma prioridad, va primero quien más minutos excedió su espera máxima" do
      assert_equal %w[ mucho poco nada ],
                   nombres_ordenados(elemento("poco", prioridad: 3, excedido: 5),
                                     elemento("nada", prioridad: 3, excedido: -20),
                                     elemento("mucho", prioridad: 3, excedido: 40))
    end

    test "si empatan en prioridad y en espera excedida, va primero quien llegó antes" do
      assert_equal %w[ temprano tarde ],
                   nombres_ordenados(elemento("tarde", prioridad: 2, llegada: AHORA - 10.minutes),
                                     elemento("temprano", prioridad: 2, llegada: AHORA - 50.minutes))
    end

    test "quienes aún no exceden su espera empatan en 0 y se ordenan por llegada" do
      assert_equal %w[ temprano tarde ],
                   nombres_ordenados(elemento("tarde", prioridad: 4, excedido: -5, llegada: AHORA - 10.minutes),
                                     elemento("temprano", prioridad: 4, excedido: -90, llegada: AHORA - 50.minutes))
    end

    test "minutos_excedidos: 0 si aún no vence y minutos completos si ya venció" do
      assert_equal 0, @priorizador.minutos_excedidos(elemento("a", prioridad: 1, excedido: -10))
      assert_equal 0, @priorizador.minutos_excedidos(elemento("b", prioridad: 1, excedido: 0))
      assert_equal 25, @priorizador.minutos_excedidos(elemento("c", prioridad: 1, excedido: 25))
    end
  end
end
