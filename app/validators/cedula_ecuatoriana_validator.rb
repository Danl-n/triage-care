# Valida una cédula ecuatoriana según las reglas del Registro Civil:
#   1. Exactamente 10 dígitos.
#   2. Los dos primeros (provincia) entre 01 y 24, o 30 (ecuatorianos en el exterior).
#   3. El tercer dígito menor que 6 (personas naturales).
#   4. El décimo dígito es el verificador del algoritmo módulo 10.
#
# Uso en cualquier modelo:  validates :cedula, cedula_ecuatoriana: true
class CedulaEcuatorianaValidator < ActiveModel::EachValidator
  COEFICIENTES = [ 2, 1, 2, 1, 2, 1, 2, 1, 2 ].freeze
  CODIGOS_PROVINCIA = ((1..24).to_a + [ 30 ]).freeze

  def validate_each(record, attribute, value)
    error = self.class.error_de(value)
    record.errors.add(attribute, error) if error
  end

  # Devuelve nil si la cédula es válida, o el símbolo del primer error encontrado.
  def self.error_de(cedula)
    cedula = cedula.to_s
    return :cedula_formato unless cedula.match?(/\A\d{10}\z/)

    digitos = cedula.chars.map(&:to_i)
    return :cedula_provincia unless CODIGOS_PROVINCIA.include?(cedula[0, 2].to_i)
    return :cedula_tercer_digito unless digitos[2] < 6
    return :cedula_verificador unless digito_verificador(digitos.first(9)) == digitos[9]

    nil
  end

  def self.valida?(cedula)
    error_de(cedula).nil?
  end

  # Módulo 10: cada dígito se multiplica por su coeficiente; si el producto es
  # mayor que 9 se le resta 9. El verificador es lo que le falta a la suma para
  # llegar a la siguiente decena (0 si la suma ya es múltiplo de 10).
  def self.digito_verificador(nueve_digitos)
    suma = nueve_digitos.zip(COEFICIENTES).sum do |digito, coeficiente|
      producto = digito * coeficiente
      producto > 9 ? producto - 9 : producto
    end
    (10 - suma % 10) % 10
  end
end
