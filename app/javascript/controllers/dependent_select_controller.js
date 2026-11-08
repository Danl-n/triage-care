import { Controller } from "@hotwired/stimulus"

// Dropdown dependiente reutilizable (Provincia → Cantón, Especialidad → Médico).
// Al cambiar el <select> padre, pide al servidor las opciones del hijo y lo vuelve a llenar.
//
// Uso en la vista:
//   <div data-controller="dependent-select"
//        data-dependent-select-url-value="/provincias/:id/cantones"
//        data-dependent-select-placeholder-value="Seleccione un cantón">
//     <select data-dependent-select-target="padre" data-action="dependent-select#cargar">
//     <select data-dependent-select-target="hijo">
//   </div>
export default class extends Controller {
  static targets = ["padre", "hijo"]
  static values = { url: String, placeholder: String }

  async cargar() {
    this.vaciarHijo()

    const padreId = this.padreTarget.value
    if (!padreId) return

    const url = this.urlValue.replace(":id", encodeURIComponent(padreId))
    const respuesta = await fetch(url, { headers: { Accept: "application/json" } })
    if (!respuesta.ok) return

    const opciones = await respuesta.json()
    opciones.forEach(({ id, nombre }) => this.hijoTarget.add(new Option(nombre, id)))
  }

  vaciarHijo() {
    this.hijoTarget.replaceChildren(new Option(this.placeholderValue, ""))
  }
}
