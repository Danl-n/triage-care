class CreateMedicos < ActiveRecord::Migration[8.1]
  def change
    create_table :medicos do |t|
      t.string :cedula, null: false, limit: 10
      t.string :nombres, null: false
      t.string :apellidos, null: false
      t.references :especialidad, null: false, foreign_key: true

      t.timestamps
    end
    add_index :medicos, :cedula, unique: true
  end
end
