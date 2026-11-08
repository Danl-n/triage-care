class CreateHospitalesReferencia < ActiveRecord::Migration[8.1]
  def change
    create_table :hospitales_referencia do |t|
      t.string :nombre, null: false
      t.references :tipo_red, null: false, foreign_key: true
      t.string :telefono

      t.timestamps
    end
    add_index :hospitales_referencia, :nombre, unique: true
  end
end
