class CreateNivelesRiesgo < ActiveRecord::Migration[8.1]
  def change
    create_table :niveles_riesgo do |t|
      t.string :nombre, null: false
      t.integer :prioridad, null: false
      t.string :criterio, null: false
      t.integer :espera_maxima_minutos, null: false
      t.integer :frecuencia_toma_minutos, null: false
      t.integer :limite_derivacion_minutos, null: false

      t.timestamps

      t.check_constraint "espera_maxima_minutos >= 0", name: "niveles_riesgo_espera_no_negativa"
      t.check_constraint "frecuencia_toma_minutos > 0", name: "niveles_riesgo_frecuencia_positiva"
      t.check_constraint "limite_derivacion_minutos > 0", name: "niveles_riesgo_limite_positivo"
    end
    add_index :niveles_riesgo, :nombre, unique: true
    add_index :niveles_riesgo, :prioridad, unique: true
  end
end
