# Datos iniciales de TriageCare. Todo es idempotente (find_or_create_by!): se puede
# ejecutar varias veces sin duplicar nada. En Render corre en cada deploy.

# --- Usuario administrador ---------------------------------------------------
# La contraseña se lee del entorno y no tiene valor por defecto (fail fast).
User.find_or_create_by!(email_address: ENV.fetch("TRIAGE_CARE_ADMIN_EMAIL", "admin@triagecare.ec")) do |user|
  user.password = ENV.fetch("TRIAGE_CARE_ADMIN_PASSWORD")
end

# --- Provincias y cantones del Ecuador ---------------------------------------
YAML.load_file(Rails.root.join("db/seeds/provincias_cantones.yml")).each do |datos|
  provincia = Provincia.find_or_create_by!(codigo: datos["codigo"]) do |nueva|
    nueva.nombre = datos["nombre"]
  end

  datos["cantones"].each do |nombre_canton|
    provincia.cantones.find_or_create_by!(nombre: nombre_canton)
  end
end

# --- Niveles de riesgo (NEWS2) -----------------------------------------------
# Solo se crean una vez: después, los tiempos se editan desde el admin y no se sobrescriben.
[
  { prioridad: 1, nombre: "Alto",       criterio: "NEWS2 de 7 o más",
    espera_maxima_minutos: 0,  frecuencia_toma_minutos: 15,  limite_derivacion_minutos: 30 },
  { prioridad: 2, nombre: "Medio",      criterio: "NEWS2 de 5 a 6",
    espera_maxima_minutos: 15, frecuencia_toma_minutos: 60,  limite_derivacion_minutos: 60 },
  { prioridad: 3, nombre: "Bajo-medio", criterio: "Algún parámetro individual con 3 puntos",
    espera_maxima_minutos: 30, frecuencia_toma_minutos: 60,  limite_derivacion_minutos: 120 },
  { prioridad: 4, nombre: "Bajo",       criterio: "NEWS2 de 0 a 4",
    espera_maxima_minutos: 120, frecuencia_toma_minutos: 240, limite_derivacion_minutos: 240 }
].each do |nivel|
  NivelRiesgo.find_or_create_by!(nombre: nivel[:nombre]) do |nuevo|
    nuevo.assign_attributes(nivel)
  end
end

# --- Datos de ejemplo --------------------------------------------------------
especialidades = [
  "Medicina de Emergencias", "Cirugía General", "Anestesiología", "Traumatología",
  "Pediatría", "Ginecología y Obstetricia", "Cardiología"
].index_with { |nombre| Especialidad.find_or_create_by!(nombre: nombre) }

medicos = [
  [ "1712345675", "Andrea",  "Paredes",  "Medicina de Emergencias" ],
  [ "1709876542", "Carlos",  "Mendoza",  "Cirugía General" ],
  [ "0912345675", "Lucía",   "Vera",     "Anestesiología" ],
  [ "1722334453", "Pablo",   "Ríos",     "Anestesiología" ],
  [ "0104567896", "Jorge",   "Cárdenas", "Traumatología" ],
  [ "1803456787", "María",   "Salazar",  "Pediatría" ],
  [ "1105678914", "Diego",   "Ortega",   "Ginecología y Obstetricia" ],
  [ "1711223345", "Sofía",   "Andrade",  "Cardiología" ]
].to_h do |cedula, nombres, apellidos, especialidad|
  medico = Medico.find_or_create_by!(cedula: cedula) do |nuevo|
    nuevo.nombres = nombres
    nuevo.apellidos = apellidos
    nuevo.especialidad = especialidades.fetch(especialidad)
  end
  [ apellidos, medico ]
end

# Los turnos dependen de la fecha: solo se generan si no hay ninguno.
if Turno.none?
  hoy = Time.zone.today.beginning_of_day
  dia = hoy + 7.hours..hoy + 19.hours
  noche = hoy + 19.hours..hoy + 31.hours

  [
    [ "Paredes",  dia,   "presencial", 0 ],
    [ "Mendoza",  dia,   "presencial", 0 ],
    [ "Vera",     dia,   "presencial", 0 ],
    [ "Ríos",     noche, "de_llamada", 30 ],
    [ "Cárdenas", dia,   "de_llamada", 20 ],
    [ "Salazar",  dia,   "presencial", 0 ],
    [ "Ortega",   noche, "de_llamada", 25 ],
    [ "Andrade",  dia,   "de_llamada", 40 ]
  ].each do |apellido, horario, modalidad, minutos|
    Turno.create!(medico: medicos.fetch(apellido), inicio: horario.begin, fin: horario.end,
                  modalidad: modalidad, tiempo_llegada_minutos: minutos)
  end
end

[
  [ "Quirófano 1", "disponible" ],
  [ "Quirófano 2", "ocupado" ],
  [ "Quirófano 3", "mantenimiento" ]
].each do |nombre, estado|
  Quirofano.find_or_create_by!(nombre: nombre) { |nuevo| nuevo.estado = estado }
end

insumos = [
  [ "Suero fisiológico 0,9 % 1000 ml", "frasco",  50 ],
  [ "Gasas estériles",                 "paquete", 200 ],
  [ "Sutura absorbible 3-0",           "unidad",  40 ],
  [ "Kit de vía periférica",           "kit",     60 ],
  [ "Venda de yeso",                   "rollo",   30 ],
  [ "Kit de cirugía menor",            "kit",     10 ],
  [ "Kit de anestesia general",        "kit",     8 ],
  [ "Cilindro de oxígeno",             "cilindro", 12 ]
].to_h do |nombre, unidad, stock|
  [ nombre, Insumo.find_or_create_by!(nombre: nombre) { |nuevo| nuevo.unidad = unidad; nuevo.stock_disponible = stock } ]
end

[
  { nombre: "Dolor torácico agudo", especialidad: "Cardiología", quirofano: false, anestesista: false, duracion: 60,
    insumos: { "Kit de vía periférica" => 1, "Suero fisiológico 0,9 % 1000 ml" => 1, "Cilindro de oxígeno" => 1 } },
  { nombre: "Apendicitis aguda", especialidad: "Cirugía General", quirofano: true, anestesista: true, duracion: 90,
    insumos: { "Kit de anestesia general" => 1, "Kit de cirugía menor" => 1, "Gasas estériles" => 2, "Sutura absorbible 3-0" => 2 } },
  { nombre: "Fractura de extremidad", especialidad: "Traumatología", quirofano: false, anestesista: false, duracion: 60,
    insumos: { "Venda de yeso" => 3, "Gasas estériles" => 1 } },
  { nombre: "Herida cortante", especialidad: "Medicina de Emergencias", quirofano: false, anestesista: false, duracion: 30,
    insumos: { "Sutura absorbible 3-0" => 1, "Gasas estériles" => 2 } },
  { nombre: "Trabajo de parto", especialidad: "Ginecología y Obstetricia", quirofano: true, anestesista: true, duracion: 120,
    insumos: { "Kit de vía periférica" => 1, "Suero fisiológico 0,9 % 1000 ml" => 2, "Gasas estériles" => 4 } },
  { nombre: "Fiebre en menor de 5 años", especialidad: "Pediatría", quirofano: false, anestesista: false, duracion: 30,
    insumos: { "Kit de vía periférica" => 1 } }
].each do |datos|
  motivo = MotivoConsulta.find_or_create_by!(nombre: datos[:nombre]) do |nuevo|
    nuevo.especialidad = especialidades.fetch(datos[:especialidad])
    nuevo.requiere_quirofano = datos[:quirofano]
    nuevo.requiere_anestesista = datos[:anestesista]
    nuevo.duracion_estimada_minutos = datos[:duracion]
  end

  datos[:insumos].each do |nombre_insumo, cantidad|
    motivo.insumos_requeridos.find_or_create_by!(insumo: insumos.fetch(nombre_insumo)) do |nuevo|
      nuevo.cantidad = cantidad
    end
  end
end

redes = {
  "Red Pública Integral de Salud (RPIS)" => "MSP, IESS, ISSFA e ISSPOL",
  "Red Privada Complementaria (RPC)" => "Clínicas y hospitales privados con convenio"
}.to_h do |nombre, descripcion|
  [ nombre, TipoRed.find_or_create_by!(nombre: nombre) { |nueva| nueva.descripcion = descripcion } ]
end

[
  [ "Hospital de Especialidades del Norte", "Red Pública Integral de Salud (RPIS)" ],
  [ "Hospital Pediátrico Regional",          "Red Pública Integral de Salud (RPIS)" ],
  [ "Clínica Privada Los Andes",             "Red Privada Complementaria (RPC)" ]
].each do |nombre, red|
  HospitalReferencia.find_or_create_by!(nombre: nombre) { |nuevo| nuevo.tipo_red = redes.fetch(red) }
end

[
  [ "1304567124", "José Luis",    "Zambrano Cedeño", "1985-03-14", "masculino", "13", "Portoviejo" ],
  [ "0918765439", "Ana María",    "Torres León",     "1992-07-02", "femenino",  "09", "Guayaquil" ],
  [ "0603456716", "Luis Alberto", "Guamán Yépez",    "1958-11-20", "masculino", "06", "Riobamba" ],
  [ "1723450985", "Valentina",    "Cevallos Mora",   "2021-05-09", "femenino",  "17", "Quito" ],
  [ "1710101013", "Rosa Elena",   "Pazmiño Vaca",    "1974-01-30", "femenino",  "17", "Rumiñahui" ],
  [ "0902020205", "Miguel Ángel", "Franco Bajaña",   "2001-09-15", "masculino", "09", "Durán" ],
  [ "0103030300", "Carmen",       "Sarmiento Ochoa", "1966-12-03", "femenino",  "01", "Cuenca" ]
].each do |cedula, nombres, apellidos, nacimiento, sexo, codigo_provincia, canton|
  Paciente.find_or_create_by!(cedula: cedula) do |nuevo|
    nuevo.nombres = nombres
    nuevo.apellidos = apellidos
    nuevo.fecha_nacimiento = Date.parse(nacimiento)
    nuevo.sexo = sexo
    nuevo.canton = Provincia.find_by!(codigo: codigo_provincia).cantones.find_by!(nombre: canton)
  end
end
