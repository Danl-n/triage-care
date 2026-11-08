class CreatePacientes < ActiveRecord::Migration[8.1]
  def change
    create_table :pacientes do |t|
      t.string :cedula, null: false, limit: 10
      t.string :nombres, null: false
      t.string :apellidos, null: false
      t.date :fecha_nacimiento, null: false
      t.string :sexo, null: false
      t.references :canton, null: false, foreign_key: true

      t.timestamps

      t.check_constraint "sexo IN ('masculino', 'femenino')", name: "pacientes_sexo_valido"
    end
    add_index :pacientes, :cedula, unique: true
  end
end
