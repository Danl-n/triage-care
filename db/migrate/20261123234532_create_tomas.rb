class CreateTomas < ActiveRecord::Migration[8.1]
  def change
    create_table :tomas do |t|
      t.references :atencion, null: false, foreign_key: true
      # "registrada_por" apunta a la tabla users: hay que decírselo a la FK con to_table.
      t.references :registrada_por, null: false, foreign_key: { to_table: :users }
      t.datetime :tomada_en, null: false

      t.integer :frecuencia_respiratoria, null: false
      t.integer :spo2, null: false
      t.boolean :con_oxigeno, null: false, default: false
      t.integer :presion_sistolica, null: false
      t.integer :pulso, null: false
      t.string :conciencia, null: false, limit: 1
      t.decimal :temperatura, null: false, precision: 3, scale: 1

      t.timestamps

      t.check_constraint "frecuencia_respiratoria BETWEEN 0 AND 80", name: "tomas_fr_en_rango"
      t.check_constraint "spo2 BETWEEN 50 AND 100", name: "tomas_spo2_en_rango"
      t.check_constraint "presion_sistolica BETWEEN 40 AND 300", name: "tomas_pas_en_rango"
      t.check_constraint "pulso BETWEEN 20 AND 250", name: "tomas_pulso_en_rango"
      t.check_constraint "conciencia IN ('A', 'C', 'V', 'P', 'U')", name: "tomas_conciencia_valida"
      t.check_constraint "temperatura BETWEEN 30.0 AND 45.0", name: "tomas_temperatura_en_rango"
    end
  end
end
