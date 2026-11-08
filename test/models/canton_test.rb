require "test_helper"

class CantonTest < ActiveSupport::TestCase
  test "no se repite el nombre dentro de la misma provincia" do
    canton = Canton.new(nombre: "Quito", provincia: provincias(:pichincha))

    assert_not canton.valid?
  end

  test "el mismo nombre puede existir en otra provincia" do
    # Ej.: "Bolívar" es cantón de Carchi y también de Manabí.
    canton = Canton.new(nombre: "Quito", provincia: provincias(:guayas))

    assert canton.valid?
  end

  test "de_provincia devuelve solo los cantones de esa provincia" do
    assert_equal [ cantones(:quito) ], Canton.de_provincia(provincias(:pichincha).id).to_a
  end
end
