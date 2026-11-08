class CreateProvincias < ActiveRecord::Migration[8.1]
  def change
    create_table :provincias do |t|
      t.string :codigo, null: false, limit: 2
      t.string :nombre, null: false

      t.timestamps
    end
    add_index :provincias, :codigo, unique: true
    add_index :provincias, :nombre, unique: true
  end
end
