require "test_helper"

class CedulaEcuatorianaValidatorTest < ActiveSupport::TestCase
  # Modelo mínimo, sin base de datos, para probar el validador de forma aislada.
  # Demuestra que el validador es reutilizable: sirve para cualquier modelo.
  class Persona
    include ActiveModel::Model
    attr_accessor :cedula
    validates :cedula, cedula_ecuatoriana: true
  end

  def errores_para(cedula)
    persona = Persona.new(cedula: cedula)
    persona.valid?
    persona.errors.details[:cedula].map { |detalle| detalle[:error] }
  end

  test "acepta cédulas válidas" do
    %w[1710034065 1712345675 0912345675 0104567896 0103030300].each do |cedula|
      assert_empty errores_para(cedula), "#{cedula} debería ser válida"
    end
  end

  test "acepta el código 30 de ecuatorianos registrados en el exterior" do
    cedula = "300000000"
    cedula += CedulaEcuatorianaValidator.digito_verificador(cedula.chars.map(&:to_i)).to_s

    assert_empty errores_para(cedula)
  end

  test "rechaza cédulas que no tienen exactamente 10 dígitos" do
    [ "171003406", "17100340655", "17100340a5", "", "1710 34065" ].each do |cedula|
      assert_equal [ :cedula_formato ], errores_para(cedula), "#{cedula.inspect} debería fallar por formato"
    end
  end

  test "rechaza códigos de provincia fuera de 01-24 y 30" do
    %w[0010034065 2510034065 2910034065 3110034065 9910034065].each do |cedula|
      assert_equal [ :cedula_provincia ], errores_para(cedula), "#{cedula} debería fallar por provincia"
    end
  end

  test "rechaza un tercer dígito mayor o igual a 6" do
    %w[1760034065 1790034065].each do |cedula|
      assert_equal [ :cedula_tercer_digito ], errores_para(cedula), "#{cedula} debería fallar por tercer dígito"
    end
  end

  test "rechaza un dígito verificador incorrecto" do
    %w[1710034060 1710034066 1712345670].each do |cedula|
      assert_equal [ :cedula_verificador ], errores_para(cedula), "#{cedula} debería fallar por verificador"
    end
  end

  test "calcula el dígito verificador con el algoritmo módulo 10" do
    # 1 7 1 0 0 3 4 0 6 × 2 1 2 1 2 1 2 1 2 = 2 7 2 0 0 3 8 0 12→3 ; suma 25 ; 30 - 25 = 5
    assert_equal 5, CedulaEcuatorianaValidator.digito_verificador([ 1, 7, 1, 0, 0, 3, 4, 0, 6 ])
  end

  test "el verificador es 0 cuando la suma ya es múltiplo de 10" do
    assert_equal 0, CedulaEcuatorianaValidator.digito_verificador([ 0, 1, 0, 3, 0, 3, 0, 3, 0 ])
  end

  test "valida? devuelve true o false" do
    assert CedulaEcuatorianaValidator.valida?("1710034065")
    assert_not CedulaEcuatorianaValidator.valida?("1710034066")
  end
end
