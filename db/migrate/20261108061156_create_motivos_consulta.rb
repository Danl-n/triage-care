class CreateMotivosConsulta < ActiveRecord::Migration[8.1]
  def change
    create_table :motivos_consulta do |t|
      t.string :nombre, null: false
      t.references :especialidad, null: false, foreign_key: true
      t.boolean :requiere_quirofano, null: false, default: false
      t.boolean :requiere_anestesista, null: false, default: false
      t.integer :duracion_estimada_minutos, null: false

      t.timestamps

      t.check_constraint "duracion_estimada_minutos > 0", name: "motivos_consulta_duracion_positiva"
    end
    add_index :motivos_consulta, :nombre, unique: true
  end
end
