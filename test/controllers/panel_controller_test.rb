require "test_helper"
# carga la configuracion comun de las pruebas (test/test_helper.rb).
# Incluye el ayudante sign_in_as

class PanelControllerTest < ActionDispatch::IntegrationTest
  # un prueba de integracion simula un navegador que hace peticiones
  # y recorre todo el ruta-> controlador -> vista.
  test "redirige al login si no hay sesion" do
    # define una prueba.
    get root_path
    # simula entrar a / sin sesion.

    assert_redirected_to new_session_path
    # comprueba que la respuesta fue redireccion al login. sino falla
  end

  test "muestra el panel con sesion iniciada" do
    sign_in_as users(:one)
    # inicia sesion como el user one

    get root_path
    # entra a / ahora con sesion

    assert_response :success
    # comprueba que respuesta = 200 ok
  end
end
