module ApplicationHelper
  # Texto en español del valor de un enum, según la sección `enums` de config/locales/es.yml.
  #   texto_enum(Turno, :modalidad, "de_llamada")  # => "De llamada"
  def texto_enum(modelo, atributo, valor)
    return "" if valor.blank?

    t("enums.#{modelo.model_name.i18n_key}.#{atributo}.#{valor}")
  end

  # Opciones [[texto, valor], ...] de un enum para usar en un <select>.
  def opciones_enum(modelo, atributo)
    modelo.defined_enums.fetch(atributo.to_s).keys.map do |valor|
      [ texto_enum(modelo, atributo, valor), valor ]
    end
  end

  def si_no(valor)
    valor ? "Sí" : "No"
  end

  def fecha_hora(valor)
    valor.present? ? l(valor, format: "%d/%m/%Y %H:%M") : ""
  end

  def fecha(valor)
    valor.present? ? l(valor, format: "%d/%m/%Y") : ""
  end
end
