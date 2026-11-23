require "test_helper"

module Triage
  class ValoradorTomaTest < ActiveSupport::TestCase
    include SignosDePrueba

    setup do
      @llegada = 1.hour.ago.change(sec: 0)
      @atencion = Atencion.create!(paciente: pacientes(:jose), motivo_consulta: motivos_consulta(:herida),
                                   hora_llegada: @llegada)
    end

    def valorar(signos, atencion: @atencion, tomada_en: @llegada + 5.minutes)
      toma = atencion.tomas.new(signos.to_h.merge(registrada_por: users(:one), tomada_en: tomada_en))
      ValoradorToma.new.valorar(toma)
    end

    test "ejemplo 1: guarda los puntajes, total 7, nivel Alto y sus tiempos" do
      toma = valorar(EJEMPLO_1)

      assert_equal [ 2, 1, 0, 1, 2, 0, 1 ],
                   toma.values_at(:puntaje_frecuencia_respiratoria, :puntaje_spo2, :puntaje_con_oxigeno,
                                  :puntaje_presion_sistolica, :puntaje_pulso, :puntaje_conciencia,
                                  :puntaje_temperatura)
      assert_equal 7, toma.puntaje_total
      assert_not toma.parametro_en_3
      assert_equal niveles_riesgo(:alto), toma.nivel_riesgo
      assert_equal @llegada, toma.espera_maxima_hasta, "Alto: llegada + 0 min"
      assert_equal toma.tomada_en + 15.minutes, toma.proxima_toma, "Alto: toma + 15 min"
      assert_not toma.alerta_deterioro
      assert toma.save
    end

    test "ejemplo 2: total 3 con la PAS en 3 → Bajo-medio" do
      toma = valorar(EJEMPLO_2)

      assert_equal 3, toma.puntaje_total
      assert toma.parametro_en_3
      assert_equal niveles_riesgo(:bajo_medio), toma.nivel_riesgo
      assert_equal @llegada + 30.minutes, toma.espera_maxima_hasta
      assert_equal toma.tomada_en + 60.minutes, toma.proxima_toma
    end

    test "ejemplo 3: una segunda toma con total 5 después del ejemplo 2 → alerta de deterioro y Medio" do
      valorar(EJEMPLO_2).save!
      segunda = EJEMPLO_2.with(frecuencia_respiratoria: 22, spo2: 95, presion_sistolica: 105, pulso: 95, temperatura: 37.0)

      toma = valorar(segunda, tomada_en: @llegada + 30.minutes)

      assert_equal 5, toma.puntaje_total
      assert_equal niveles_riesgo(:medio), toma.nivel_riesgo
      assert toma.alerta_deterioro
      assert_equal @llegada + 15.minutes, toma.espera_maxima_hasta, "Medio: llegada + 15 min"
    end

    test "no hay alerta si el total sube solo 1 punto" do
      valorar(EJEMPLO_2).save!
      segunda = EJEMPLO_2.with(pulso: 95)

      assert_not valorar(segunda, tomada_en: @llegada + 30.minutes).alerta_deterioro
    end

    test "compara con la toma inmediatamente anterior, no con la primera" do
      valorar(EJEMPLO_2).save!                                                      # total 3
      valorar(EJEMPLO_2.with(pulso: 95), tomada_en: @llegada + 20.minutes).save!    # total 4

      tercera = valorar(EJEMPLO_2.with(pulso: 95, temperatura: 38.5), tomada_en: @llegada + 40.minutes) # total 5

      assert_not tercera.alerta_deterioro, "sube 1 frente a la anterior (aunque 2 frente a la primera)"
    end

    test "usa la escala 2 de SpO2 cuando la atención la tiene activa" do
      @atencion.update!(usa_escala_spo2_2: true)

      toma = valorar(EJEMPLO_2.with(con_oxigeno: true))

      assert_equal 3, toma.puntaje_spo2, "SpO2 97 con oxígeno en la escala 2"
    end

    test "usa los tiempos configurados en el nivel de riesgo" do
      niveles_riesgo(:alto).update!(espera_maxima_minutos: 5, frecuencia_toma_minutos: 10)

      toma = valorar(EJEMPLO_1)

      assert_equal @llegada + 5.minutes, toma.espera_maxima_hasta
      assert_equal toma.tomada_en + 10.minutes, toma.proxima_toma
    end
  end
end
