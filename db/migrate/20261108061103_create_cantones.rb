class CreateCantones < ActiveRecord::Migration[8.1]
  def change
    create_table :cantones do |t|
      t.string :nombre, null: false
      t.references :provincia, null: false, foreign_key: true

      t.timestamps
    end
    add_index :cantones, [ :provincia_id, :nombre ], unique: true
  end
end
