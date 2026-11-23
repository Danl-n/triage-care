# El resultado del cálculo se guarda en la misma fila de la toma (relación 1 a 1 con sus signos).
# Las columnas son NOT NULL sin default: una toma nunca existe sin su valoración.
# (Agregar columnas NOT NULL sin default solo funciona si la tabla está vacía.)
class AddResultadoToTomas < ActiveRecord::Migration[8.1]
  def change
    change_table :tomas, bulk: true do |t|
      t.integer :puntaje_frecuencia_respiratoria, null: false
      t.integer :puntaje_spo2, null: false
      t.integer :puntaje_con_oxigeno, null: false
      t.integer :puntaje_presion_sistolica, null: false
      t.integer :puntaje_pulso, null: false
      t.integer :puntaje_conciencia, null: false
      t.integer :puntaje_temperatura, null: false
      t.integer :puntaje_total, null: false
      t.boolean :parametro_en_3, null: false
      t.references :nivel_riesgo, null: false, foreign_key: true
      t.datetime :espera_maxima_hasta, null: false
      t.datetime :proxima_toma, null: false
      t.boolean :alerta_deterioro, null: false
    end
  end
end
