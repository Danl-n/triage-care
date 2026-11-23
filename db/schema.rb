# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_23_234532) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "atenciones", force: :cascade do |t|
    t.bigint "paciente_id", null: false
    t.bigint "motivo_consulta_id", null: false
    t.datetime "hora_llegada", null: false
    t.string "estado", default: "en_espera", null: false
    t.boolean "usa_escala_spo2_2", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estado", "hora_llegada"], name: "index_atenciones_on_estado_and_hora_llegada"
    t.index ["motivo_consulta_id"], name: "index_atenciones_on_motivo_consulta_id"
    t.index ["paciente_id"], name: "index_atenciones_abierta_unica_por_paciente", unique: true, where: "((estado)::text = ANY ((ARRAY['en_espera'::character varying, 'en_atencion'::character varying])::text[]))"
    t.index ["paciente_id"], name: "index_atenciones_on_paciente_id"
    t.check_constraint "estado::text = ANY (ARRAY['en_espera'::character varying, 'en_atencion'::character varying, 'finalizada'::character varying, 'derivada'::character varying]::text[])", name: "atenciones_estado_valido"
  end

  create_table "cantones", force: :cascade do |t|
    t.string "nombre", null: false
    t.bigint "provincia_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provincia_id", "nombre"], name: "index_cantones_on_provincia_id_and_nombre", unique: true
    t.index ["provincia_id"], name: "index_cantones_on_provincia_id"
  end

  create_table "especialidades", force: :cascade do |t|
    t.string "nombre", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_especialidades_on_nombre", unique: true
  end

  create_table "hospitales_referencia", force: :cascade do |t|
    t.string "nombre", null: false
    t.bigint "tipo_red_id", null: false
    t.string "telefono"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_hospitales_referencia_on_nombre", unique: true
    t.index ["tipo_red_id"], name: "index_hospitales_referencia_on_tipo_red_id"
  end

  create_table "insumos", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "unidad", null: false
    t.integer "stock_disponible", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_insumos_on_nombre", unique: true
    t.check_constraint "stock_disponible >= 0", name: "insumos_stock_no_negativo"
  end

  create_table "insumos_requeridos", force: :cascade do |t|
    t.bigint "motivo_consulta_id", null: false
    t.bigint "insumo_id", null: false
    t.integer "cantidad", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insumo_id"], name: "index_insumos_requeridos_on_insumo_id"
    t.index ["motivo_consulta_id", "insumo_id"], name: "index_insumos_requeridos_on_motivo_consulta_id_and_insumo_id", unique: true
    t.index ["motivo_consulta_id"], name: "index_insumos_requeridos_on_motivo_consulta_id"
    t.check_constraint "cantidad > 0", name: "insumos_requeridos_cantidad_positiva"
  end

  create_table "medicos", force: :cascade do |t|
    t.string "cedula", limit: 10, null: false
    t.string "nombres", null: false
    t.string "apellidos", null: false
    t.bigint "especialidad_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cedula"], name: "index_medicos_on_cedula", unique: true
    t.index ["especialidad_id"], name: "index_medicos_on_especialidad_id"
  end

  create_table "motivos_consulta", force: :cascade do |t|
    t.string "nombre", null: false
    t.bigint "especialidad_id", null: false
    t.boolean "requiere_quirofano", default: false, null: false
    t.boolean "requiere_anestesista", default: false, null: false
    t.integer "duracion_estimada_minutos", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["especialidad_id"], name: "index_motivos_consulta_on_especialidad_id"
    t.index ["nombre"], name: "index_motivos_consulta_on_nombre", unique: true
    t.check_constraint "duracion_estimada_minutos > 0", name: "motivos_consulta_duracion_positiva"
  end

  create_table "niveles_riesgo", force: :cascade do |t|
    t.string "nombre", null: false
    t.integer "prioridad", null: false
    t.string "criterio", null: false
    t.integer "espera_maxima_minutos", null: false
    t.integer "frecuencia_toma_minutos", null: false
    t.integer "limite_derivacion_minutos", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_niveles_riesgo_on_nombre", unique: true
    t.index ["prioridad"], name: "index_niveles_riesgo_on_prioridad", unique: true
    t.check_constraint "espera_maxima_minutos >= 0", name: "niveles_riesgo_espera_no_negativa"
    t.check_constraint "frecuencia_toma_minutos > 0", name: "niveles_riesgo_frecuencia_positiva"
    t.check_constraint "limite_derivacion_minutos > 0", name: "niveles_riesgo_limite_positivo"
  end

  create_table "pacientes", force: :cascade do |t|
    t.string "cedula", limit: 10, null: false
    t.string "nombres", null: false
    t.string "apellidos", null: false
    t.date "fecha_nacimiento", null: false
    t.string "sexo", null: false
    t.bigint "canton_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canton_id"], name: "index_pacientes_on_canton_id"
    t.index ["cedula"], name: "index_pacientes_on_cedula", unique: true
    t.check_constraint "sexo::text = ANY (ARRAY['masculino'::character varying, 'femenino'::character varying]::text[])", name: "pacientes_sexo_valido"
  end

  create_table "provincias", force: :cascade do |t|
    t.string "codigo", limit: 2, null: false
    t.string "nombre", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_provincias_on_codigo", unique: true
    t.index ["nombre"], name: "index_provincias_on_nombre", unique: true
  end

  create_table "quirofanos", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "estado", default: "disponible", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_quirofanos_on_nombre", unique: true
    t.check_constraint "estado::text = ANY (ARRAY['disponible'::character varying, 'ocupado'::character varying, 'mantenimiento'::character varying]::text[])", name: "quirofanos_estado_valido"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tipos_red", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_tipos_red_on_nombre", unique: true
  end

  create_table "tomas", force: :cascade do |t|
    t.bigint "atencion_id", null: false
    t.bigint "registrada_por_id", null: false
    t.datetime "tomada_en", null: false
    t.integer "frecuencia_respiratoria", null: false
    t.integer "spo2", null: false
    t.boolean "con_oxigeno", default: false, null: false
    t.integer "presion_sistolica", null: false
    t.integer "pulso", null: false
    t.string "conciencia", limit: 1, null: false
    t.decimal "temperatura", precision: 3, scale: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["atencion_id"], name: "index_tomas_on_atencion_id"
    t.index ["registrada_por_id"], name: "index_tomas_on_registrada_por_id"
    t.check_constraint "conciencia::text = ANY (ARRAY['A'::character varying, 'C'::character varying, 'V'::character varying, 'P'::character varying, 'U'::character varying]::text[])", name: "tomas_conciencia_valida"
    t.check_constraint "frecuencia_respiratoria >= 0 AND frecuencia_respiratoria <= 80", name: "tomas_fr_en_rango"
    t.check_constraint "presion_sistolica >= 40 AND presion_sistolica <= 300", name: "tomas_pas_en_rango"
    t.check_constraint "pulso >= 20 AND pulso <= 250", name: "tomas_pulso_en_rango"
    t.check_constraint "spo2 >= 50 AND spo2 <= 100", name: "tomas_spo2_en_rango"
    t.check_constraint "temperatura >= 30.0 AND temperatura <= 45.0", name: "tomas_temperatura_en_rango"
  end

  create_table "turnos", force: :cascade do |t|
    t.bigint "medico_id", null: false
    t.datetime "inicio", null: false
    t.datetime "fin", null: false
    t.string "modalidad", null: false
    t.integer "tiempo_llegada_minutos", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inicio", "fin"], name: "index_turnos_on_inicio_and_fin"
    t.index ["medico_id"], name: "index_turnos_on_medico_id"
    t.check_constraint "fin > inicio", name: "turnos_fin_despues_de_inicio"
    t.check_constraint "modalidad::text = ANY (ARRAY['presencial'::character varying, 'de_llamada'::character varying]::text[])", name: "turnos_modalidad_valida"
    t.check_constraint "tiempo_llegada_minutos >= 0", name: "turnos_tiempo_llegada_no_negativo"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "atenciones", "motivos_consulta"
  add_foreign_key "atenciones", "pacientes"
  add_foreign_key "cantones", "provincias"
  add_foreign_key "hospitales_referencia", "tipos_red"
  add_foreign_key "insumos_requeridos", "insumos"
  add_foreign_key "insumos_requeridos", "motivos_consulta"
  add_foreign_key "medicos", "especialidades"
  add_foreign_key "motivos_consulta", "especialidades"
  add_foreign_key "pacientes", "cantones"
  add_foreign_key "sessions", "users"
  add_foreign_key "tomas", "atenciones"
  add_foreign_key "tomas", "users", column: "registrada_por_id"
  add_foreign_key "turnos", "medicos"
end
