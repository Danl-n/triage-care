require "test_helper"

class ProvinciaTest < ActiveSupport::TestCase
  test "el código debe estar entre 01 y 24" do
    provincia = Provincia.new(codigo: "30", nombre: "Exterior")

    assert_not provincia.valid?
    assert provincia.errors.key?(:codigo)
  end

  test "el nombre es único sin importar mayúsculas" do
    provincia = Provincia.new(codigo: "18", nombre: "  pichincha ")

    assert_not provincia.valid?
    assert_includes provincia.errors.details[:nombre].map { |d| d[:error] }, :taken
  end

  test "no se puede eliminar una provincia que tiene cantones" do
    provincia = provincias(:pichincha)

    assert_not provincia.destroy
    assert provincia.errors.any?
  end
end
