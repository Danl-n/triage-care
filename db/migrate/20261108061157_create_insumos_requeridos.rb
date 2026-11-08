class CreateInsumosRequeridos < ActiveRecord::Migration[8.1]
  def change
    create_table :insumos_requeridos do |t|
      t.references :motivo_consulta, null: false, foreign_key: true
      t.references :insumo, null: false, foreign_key: true
      t.integer :cantidad, null: false

      t.timestamps

      t.check_constraint "cantidad > 0", name: "insumos_requeridos_cantidad_positiva"
    end
    add_index :insumos_requeridos, [ :motivo_consulta_id, :insumo_id ], unique: true
  end
end
