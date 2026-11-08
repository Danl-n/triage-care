class CreateTiposRed < ActiveRecord::Migration[8.1]
  def change
    create_table :tipos_red do |t|
      t.string :nombre, null: false
      t.string :descripcion

      t.timestamps
    end
    add_index :tipos_red, :nombre, unique: true
  end
end
