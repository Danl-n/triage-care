class CreateAtenciones < ActiveRecord::Migration[8.1]
  def change
    create_table :atenciones do |t|
      t.references :paciente, null: false, foreign_key: true
      t.references :motivo_consulta, null: false, foreign_key: true
      t.datetime :hora_llegada, null: false
      t.string :estado, null: false, default: "en_espera"
      t.boolean :usa_escala_spo2_2, null: false, default: false

      t.timestamps

      t.check_constraint "estado IN ('en_espera', 'en_atencion', 'finalizada', 'derivada')",
                         name: "atenciones_estado_valido"
    end

    # Índice único PARCIAL: un paciente puede tener muchas atenciones cerradas,
    # pero solo una abierta (en espera o en atención) a la vez.
    add_index :atenciones, :paciente_id, unique: true,
              where: "estado IN ('en_espera', 'en_atencion')",
              name: "index_atenciones_abierta_unica_por_paciente"
    add_index :atenciones, [ :estado, :hora_llegada ]
  end
end
