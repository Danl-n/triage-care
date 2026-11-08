require "test_helper"

class InsumosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @insumo = insumos(:sutura)
    sign_in_as users(:one)
  end

  test "lista, muestra y abre los formularios" do
    get insumos_path
    assert_response :success

    get insumo_path(@insumo)
    assert_response :success

    get new_insumo_path
    assert_response :success

    get edit_insumo_path(@insumo)
    assert_response :success
  end

  test "crea, actualiza y elimina un insumo" do
    assert_difference("Insumo.count") do
      post insumos_path, params: { insumo: { nombre: "Venda de yeso", unidad: "rollo", stock_disponible: 30 } }
    end
    assert_redirected_to insumo_path(Insumo.last)

    patch insumo_path(@insumo), params: { insumo: { stock_disponible: 5 } }
    assert_equal 5, @insumo.reload.stock_disponible

    assert_difference("Insumo.count", -1) do
      delete insumo_path(@insumo)
    end
  end

  test "rechaza stock negativo" do
    post insumos_path, params: { insumo: { nombre: "Guantes", unidad: "caja", stock_disponible: -1 } }

    assert_response :unprocessable_content
  end
end
