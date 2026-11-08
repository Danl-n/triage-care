# TriageCare — Módulo de administración

Aplicación web MVC en **Ruby on Rails 8.1** para la sala de emergencias de un hospital genérico.
Esta entrega implementa el **módulo de administración**, que alimenta con datos al core del sistema.

🌐 **Producción:** https://triage-care-j3yl.onrender.com
*(plan gratuito de Render: la primera visita después de un rato de inactividad tarda alrededor de un minuto en responder)*

---

## 1. ¿Qué es TriageCare?

El core del sistema (próximas entregas) tiene dos etapas:

1. **Valoración clínica:** con los signos vitales calcula el puntaje **NEWS2**, asigna un **nivel de riesgo**
   (Alto, Medio, Bajo-medio, Bajo) y arma una **cola priorizada**.
2. **Asignación de recursos:** según el **motivo de consulta**, busca un especialista de turno (presencial o de
   llamada), un anestesista, un quirófano y los insumos, y propone un plan: *atender ahora*, *esperar recurso*,
   *llamar especialista* o *recomendar derivación*.

Este módulo administra **todos los datos que esas dos etapas necesitan**.

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

## 5. Arquitectura y decisiones

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
Provincia 1──* Canton 1──* Paciente
Especialidad 1──* Medico 1──* Turno
Especialidad 1──* MotivoConsulta *──* Insumo   (a través de InsumoRequerido con cantidad)
TipoRed 1──* HospitalReferencia
Quirofano   NivelRiesgo   User 1──* Session
```

## 6. Instalación local

**Requisitos:** Ruby 3.4, PostgreSQL 16 o superior y Git.

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

## 7. Pruebas

```bash
bin/rails db:test:prepare
bin/rails test
```

**86 pruebas (Minitest):**
- Validador de cédula: casos válidos, código 30, formato, provincia, tercer dígito y verificador.
- Modelos: Paciente, Turno, Provincia, Cantón, Motivo de consulta y Usuario.
- Controladores: login obligatorio, CRUD completo de cada entidad, endpoints JSON de los dropdowns y rechazo de
  formularios manipulados (cantón de otra provincia, médico de otra especialidad).

Calidad: `bin/rubocop` (sin observaciones) y `bin/brakeman` (sin advertencias).

## 8. Despliegue en Render

1. Crear una base **PostgreSQL** (plan gratuito) y copiar su *Internal Database URL*.
2. Crear un **Web Service** desde este repositorio, en la misma región que la base:
   - Build Command: `./bin/render-build.sh` (instala gemas, compila assets, migra y ejecuta los seeds)
   - Start Command: `bundle exec puma -C config/puma.rb`
3. Variables de entorno: `RAILS_ENV=production`, `DATABASE_URL`, `RAILS_MASTER_KEY` (contenido de
   `config/master.key`), `TRIAGE_CARE_ADMIN_PASSWORD` y `WEB_CONCURRENCY=0` (un solo proceso; el plan gratuito
   tiene 512 MB de RAM).

Los seeds son **idempotentes** (`find_or_create_by!`), por eso es seguro ejecutarlos en cada deploy.
La base gratuita de Render vence a los 30 días: para recrearla basta con una base nueva y un nuevo deploy.

## 9. Fuera del alcance de esta entrega

Atenciones, tomas de signos vitales, cálculo de NEWS2, asignación de recursos y roles y permisos.
