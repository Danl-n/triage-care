class CreateQuirofanos < ActiveRecord::Migration[8.1]
  def change
    create_table :quirofanos do |t|
      t.string :nombre, null: false
      t.string :estado, null: false, default: "disponible"

      t.timestamps

      t.check_constraint "estado IN ('disponible', 'ocupado', 'mantenimiento')", name: "quirofanos_estado_valido"
    end
    add_index :quirofanos, :nombre, unique: true
  end
end
