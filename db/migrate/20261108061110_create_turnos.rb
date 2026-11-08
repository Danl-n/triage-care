class CreateTurnos < ActiveRecord::Migration[8.1]
  def change
    create_table :turnos do |t|
      t.references :medico, null: false, foreign_key: true
      t.datetime :inicio, null: false
      t.datetime :fin, null: false
      t.string :modalidad, null: false
      t.integer :tiempo_llegada_minutos, null: false, default: 0

      t.timestamps

      t.check_constraint "fin > inicio", name: "turnos_fin_despues_de_inicio"
      t.check_constraint "modalidad IN ('presencial', 'de_llamada')", name: "turnos_modalidad_valida"
      t.check_constraint "tiempo_llegada_minutos >= 0", name: "turnos_tiempo_llegada_no_negativo"
    end
    add_index :turnos, [ :inicio, :fin ]
  end
end
