# TriageCare — Administración y etapa 1 del core (valoración clínica)

Aplicación web MVC en **Ruby on Rails 8.1** para la sala de emergencias de un hospital genérico.
Incluye el **módulo de administración** (tag `v1.0-admin`) y la **etapa 1 del core**: atenciones, tomas de
signos vitales, cálculo **NEWS2**, nivel de riesgo y **cola priorizada**.

🌐 **Producción:** https://triage-care-j3yl.onrender.com
*(plan gratuito de Render: la primera visita después de un rato de inactividad tarda alrededor de un minuto en responder)*

---

## 1. ¿Qué es TriageCare?

El core del sistema tiene dos etapas:

1. **Valoración clínica** *(implementada, ver sección 5)*: con los signos vitales calcula el puntaje **NEWS2**, asigna un **nivel de riesgo**
   (Alto, Medio, Bajo-medio, Bajo) y arma una **cola priorizada**.
2. **Asignación de recursos:** según el **motivo de consulta**, busca un especialista de turno (presencial o de
   llamada), un anestesista, un quirófano y los insumos, y propone un plan: *atender ahora*, *esperar recurso*,
   *llamar especialista* o *recomendar derivación* *(próxima entrega)*.

El módulo de administración gestiona **todos los datos que esas dos etapas necesitan**.

## 2. Requisitos de la entrega y cómo se cumplen

| Requisito | Implementación |
|---|---|
| Validación back-end de un dato sensible antes de guardar | **Cédula ecuatoriana** con un validador propio y reutilizable: [`app/validators/cedula_ecuatoriana_validator.rb`](app/validators/cedula_ecuatoriana_validator.rb). Se usa en `Paciente` y en `Medico`. Pruebas unitarias en [`test/validators/`](test/validators/cedula_ecuatoriana_validator_test.rb). |
| Claves foráneas solo con dropdowns | Todas las FK se eligen con `<select>` (`collection_select`); nunca se escribe un ID. |
| Dropdowns dependientes | **Provincia → Cantón** (Paciente) y **Especialidad → Médico** (Turno), con un único controlador Stimulus reutilizable: [`dependent_select_controller.js`](app/javascript/controllers/dependent_select_controller.js). |
| El back-end verifica que el hijo pertenece al padre | `Paciente#canton_pertenece_a_la_provincia` y `Turno#medico_pertenece_a_la_especialidad`. Hay pruebas que envían datos manipulados y comprueban que se rechazan. |
| Git, README y despliegue | Este repositorio, este archivo y Render con PostgreSQL. |
| Login | Generador de autenticación nativo de Rails 8 (`has_secure_password` + bcrypt). Todas las rutas están protegidas por defecto. |

## 3. Funcionalidades

CRUD de:

| Grupo | Entidades |
|---|---|
| Ubicación | Provincia, Cantón |
| Pacientes | Paciente (cédula, nombres, apellidos, fecha de nacimiento, sexo, cantón) |
| Personal | Especialidad, Médico, Turno (inicio, fin, modalidad presencial o de llamada, tiempo de llegada) |
| Recursos | Quirófano (disponible, ocupado o en mantenimiento), Insumo (unidad, stock), Motivo de consulta (especialidad, requiere quirófano o anestesista, duración e **insumos requeridos con cantidad**) |
| Derivación | Tipo de red, Hospital de referencia |
| Riesgo | Nivel de riesgo: los 4 niveles se cargan por seed y **solo se editan** la espera máxima, la frecuencia de toma de signos y el límite de derivación |
| Triaje (etapa 1) | Atención (CRUD), Toma de signos (registrar y consultar) y **cola priorizada** |

### Reglas de negocio validadas en el back-end
- **Cédula:** 10 dígitos; provincia de 01 a 24 o 30; tercer dígito menor que 6; dígito verificador con módulo 10; sin duplicados.
- **Paciente:** el cantón pertenece a la provincia elegida; la fecha de nacimiento no puede ser futura.
- **Turno:** el médico pertenece a la especialidad elegida; el fin es posterior al inicio; un turno presencial tiene
  tiempo de llegada 0 y uno de llamada, mayor que 0; un médico no puede tener dos turnos que se crucen.
- **Motivo de consulta:** cantidades positivas y sin insumos repetidos.
- **Integridad:** no se puede eliminar un registro del que dependen otros (por ejemplo, una provincia con cantones).

Cada regla existe en **dos capas** (defensa en profundidad): validaciones del **modelo**, que dan mensajes
claros al usuario, y restricciones de **PostgreSQL** (`NOT NULL`, índices únicos, claves foráneas y `CHECK`),
que protegen los datos aunque alguien se salte el modelo.

## 4. Algoritmo de validación de la cédula

```
Cédula:        1  7  1  0  0  3  4  0  6 | 5   ← el décimo dígito es el verificador
Coeficientes:  2  1  2  1  2  1  2  1  2
Productos:     2  7  2  0  0  3  8  0 12
Si > 9, −9:    2  7  2  0  0  3  8  0  3   → suma = 25
Verificador:   (10 − 25 mod 10) mod 10 = 5  ✔ coincide
```

Uso en cualquier modelo: `validates :cedula, cedula_ecuatoriana: true`.
Cada regla incumplida produce su propio mensaje en español (configurado en `config/locales/es.yml`).

## 5. Etapa 1 del core: valoración clínica

### Flujo
1. **Atención:** se registra la llegada de un paciente con su motivo de consulta (dropdowns). Estados:
   *en espera*, *en atención*, *finalizada* y *derivada*. **Un paciente solo puede tener una atención abierta**
   (en espera o en atención): lo valida el modelo y lo garantiza un **índice único parcial** en PostgreSQL.
2. **Toma de signos:** FR, SpO2, oxígeno suplementario, presión sistólica, pulso, conciencia (ACVPU) y temperatura,
   con quién la registró y la hora. Rangos validados en el back-end (y con `CHECK` en la base):
   FR 0–80 · SpO2 50–100 · PAS 40–300 · pulso 20–250 · temperatura 30,0–45,0. Una atención finalizada o derivada
   no admite tomas. Las tomas **no se editan ni se borran** (registro clínico): una corrección es una toma nueva.
3. **Valoración:** al guardar la toma se calculan y **guardan en la misma fila** el puntaje de cada parámetro,
   el total, si algún parámetro vale 3, el nivel de riesgo, la espera máxima, la próxima toma y la alerta de deterioro.
4. **Cola priorizada:** atenciones en espera ordenadas por **prioridad del nivel** (Alto primero), luego por
   **minutos de espera excedida** (de mayor a menor) y luego por **hora de llegada**. Las que aún no tienen toma
   se muestran aparte, como *pendientes de primera toma*.

### Tabla NEWS2 (límites inclusivos)

| Parámetro | 3 | 2 | 1 | 0 | 1 | 2 | 3 |
|---|---|---|---|---|---|---|---|
| FR (rpm) | ≤ 8 | | 9–11 | 12–20 | | 21–24 | ≥ 25 |
| SpO2 escala 1 (%) | ≤ 91 | 92–93 | 94–95 | ≥ 96 | | | |
| SpO2 escala 2 (%) | ≤ 83 | 84–85 | 86–87 | 88–92 o ≥ 93 con aire | 93–94 con O2 | 95–96 con O2 | ≥ 97 con O2 |
| Oxígeno | | oxígeno | | aire | | | |
| PAS (mmHg) | ≤ 90 | 91–100 | 101–110 | 111–219 | | | ≥ 220 |
| Pulso (lpm) | ≤ 40 | | 41–50 | 51–90 | 91–110 | 111–130 | ≥ 131 |
| Conciencia | | | | A | | | C, V, P o U |
| Temperatura (°C) | ≤ 35,0 | | 35,1–36,0 | 36,1–38,0 | 38,1–39,0 | ≥ 39,1 | |

**Nivel de riesgo** (vale la primera condición que se cumpla): total ≥ 7 → **Alto** · total 5–6 → **Medio** ·
algún parámetro con 3 → **Bajo-medio** · cualquier otro caso → **Bajo**. Se usan los 4 niveles del seed, con sus
tiempos editables desde el admin.

**Tiempos y alertas:** `espera_maxima_hasta` = hora de llegada + espera máxima del nivel ·
`proxima_toma` = hora de la toma + frecuencia del nivel · **alerta de deterioro** si el total sube 2 o más puntos
frente a la toma anterior de la misma atención.

| Ejemplo | Signos | Resultado |
|---|---|---|
| 1 | FR 23, SpO2 94, aire, PAS 105, pulso 112, A, 38,4 °C | 2+1+0+1+2+0+1 = **7 → Alto** |
| 2 | FR 18, SpO2 97, aire, PAS 88, pulso 80, A, 36,8 °C | **3 → Bajo-medio** (la PAS vale 3) |
| 3 | Segunda toma con total 5 después del ejemplo 2 | **Medio y alerta de deterioro** (+2) |

### Arquitectura del core

La lógica vive en **objetos de Ruby puro** en [`app/services/triage/`](app/services/triage/), sin depender de
controladores ni vistas, y se prueba sin interfaz:

```
TomasController#create ── solo orquesta: arma la toma, valora, guarda y redirige
        │
        ▼
Triage::ValoradorToma  (Facade)
   ├── FabricaPuntuadorSpo2.para(escala_2:)   (Factory) ──► PuntuadorSpo2EscalaUno | PuntuadorSpo2EscalaDos  (Strategy)
   ├── CalculadoraNews2.new(puntuador_spo2:).calcular(toma) ──► ResultadoNews2 (valor inmutable: puntajes, total)
   ├── ClasificadorRiesgo#clasificar(resultado) ──► "Alto" | "Medio" | "Bajo-medio" | "Bajo"
   └── nivel de riesgo (BD) ──► espera máxima, próxima toma y alerta de deterioro

ColaController#index ──► Triage::PriorizadorCola.new(ahora:).ordenar(atenciones)
```

- **SRP:** cada clase tiene una sola razón de cambio (las tablas NEWS2, el criterio de riesgo, el orden de la cola...).
- **Abierto/cerrado + Strategy:** una nueva escala de SpO2 es una clase nueva más una línea en la fábrica; la
  calculadora no cambia.
- **Liskov:** las dos escalas tienen la misma interfaz `puntuar(spo2, con_oxigeno:)` y son intercambiables.
- **Inversión de dependencias:** la calculadora recibe la escala por el constructor; el priorizador recibe la hora
  actual. Por eso las pruebas usan objetos `Data` en lugar de registros de la base.

## 6. Arquitectura y decisiones

- **MVC de Rails:** los modelos tienen las reglas de negocio; los controladores solo coordinan
  (patrón de 7 acciones REST, *strong parameters* con `params.expect`); las vistas solo muestran.
- **Modelos en español** con plurales irregulares declarados en [`config/initializers/inflections.rb`](config/initializers/inflections.rb)
  (`provincias`, `cantones`, `especialidades`, `motivos_consulta`, `niveles_riesgo`...).
- **Dropdowns dependientes:** cada padre expone un endpoint JSON (`GET /provincias/:id/cantones` y
  `GET /especialidades/:id/medicos`). El controlador Stimulus recibe la URL por atributos `data-*`, así que la
  misma pieza sirve para cualquier jerarquía (principio abierto/cerrado).
- **Atributos virtuales** (`provincia_id` en Paciente, `especialidad_id` en Turno): viajan en el formulario para
  armar el dropdown y para la verificación en el back-end, pero no se guardan, porque se deducen del hijo (normalización).
- **Interfaz en español** con `rails-i18n` y zona horaria `America/Guayaquil`.
- **Seguridad:** autenticación con bcrypt, secretos solo en variables de entorno, *rate limit* en el login,
  `force_ssl` en producción. Brakeman: 0 advertencias.

### Modelo de datos

```
Provincia 1──* Canton 1──* Paciente 1──* Atencion *──1 MotivoConsulta
                                          Atencion 1──* Toma *──1 NivelRiesgo
                                          Toma *──1 User (registrada_por)
Especialidad 1──* Medico 1──* Turno
Especialidad 1──* MotivoConsulta *──* Insumo   (a través de InsumoRequerido con cantidad)
TipoRed 1──* HospitalReferencia
Quirofano   User 1──* Session
```

## 7. Instalación local

**Requisitos:** Ruby 3.4.13 o superior, PostgreSQL 16 o superior y Git.

```bash
git clone https://github.com/Danl-n/triage-care.git
cd triage-care
bundle install
```

Variables de entorno (no se guardan en el repositorio):

| Variable | Uso |
|---|---|
| `TRIAGE_CARE_DB_PASSWORD` | Contraseña del usuario `postgres` local |
| `TRIAGE_CARE_ADMIN_PASSWORD` | Contraseña del administrador que crean los seeds |
| `TRIAGE_CARE_ADMIN_EMAIL` | *(opcional)* correo del administrador; por defecto `admin@triagecare.ec` |

```bash
bin/rails db:create db:migrate db:seed
bin/rails server
```

Abrir http://localhost:3000 e ingresar con el correo del administrador y la contraseña definida.

### Particularidades de Windows
- Después de cada migración, ejecutar también `bin/rails db:test:prepare`: en Windows, Rails no prepara
  automáticamente la base de pruebas.
- En PowerShell, una variable para la terminal actual se define así: `$env:TRIAGE_CARE_ADMIN_PASSWORD = "..."`.

## 8. Pruebas

```bash
bin/rails db:test:prepare
bin/rails test
```

**175 pruebas (Minitest):**
- Validador de cédula: casos válidos, código 30, formato, provincia, tercer dígito y verificador.
- Modelos: Paciente, Turno, Provincia, Cantón, Motivo de consulta, Usuario, **Atención** (una sola abierta por
  paciente) y **Toma** (cada rango, con sus dos límites).
- **Servicios del core** ([`test/services/triage/`](test/services/triage/)): los límites de cada tabla NEWS2
  (por ejemplo FR 8/9, 20/21, 24/25 y temperatura 35,0/35,1), las dos escalas de SpO2, la fábrica, el clasificador,
  el priorizador de la cola y los **ejemplos 1, 2 y 3** del enunciado.
- Controladores: login obligatorio, CRUD completo de cada entidad, endpoints JSON de los dropdowns, rechazo de
  formularios manipulados (cantón de otra provincia, médico de otra especialidad), registro de tomas y cola.

La lógica del core se desarrolló con **TDD**: en el historial, cada commit `test(triage): ... (en rojo)` va seguido
del commit `feat(triage): ...` que pone las pruebas en verde.

Calidad: `bin/rubocop` (sin observaciones) y `bin/brakeman` (sin advertencias).

## 9. Despliegue en Render

1. Crear una base **PostgreSQL** (plan gratuito) y copiar su *Internal Database URL*.
2. Crear un **Web Service** desde este repositorio, en la misma región que la base:
   - Build Command: `./bin/render-build.sh` (instala gemas, compila assets, migra y ejecuta los seeds)
   - Start Command: `bundle exec puma -C config/puma.rb`
3. Variables de entorno: `RAILS_ENV=production`, `DATABASE_URL`, `RAILS_MASTER_KEY` (contenido de
   `config/master.key`), `TRIAGE_CARE_ADMIN_PASSWORD` y `WEB_CONCURRENCY=0` (un solo proceso; el plan gratuito
   tiene 512 MB de RAM).

Los seeds son **idempotentes** (`find_or_create_by!`), por eso es seguro ejecutarlos en cada deploy.
La base gratuita de Render vence a los 30 días: para recrearla basta con una base nueva y un nuevo deploy.

Los seeds también crean **atenciones y tomas de ejemplo** (los ejemplos 1, 2 y 3, la escala 2 de SpO2, una
atención sin toma y una finalizada), pero solo si todavía no hay atenciones.

## 10. Fuera del alcance de esta entrega

Etapa 2 del core (asignación de recursos, planes y derivación), roles y permisos, hora simulada, activar la
escala 2 de SpO2 desde la interfaz (por ahora se fija en la atención por seed o consola) y diseño visual.
