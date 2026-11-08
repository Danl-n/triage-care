class CreateInsumos < ActiveRecord::Migration[8.1]
  def change
    create_table :insumos do |t|
      t.string :nombre, null: false
      t.string :unidad, null: false
      t.integer :stock_disponible, null: false, default: 0

      t.timestamps

      t.check_constraint "stock_disponible >= 0", name: "insumos_stock_no_negativo"
    end
    add_index :insumos, :nombre, unique: true
  end
end
