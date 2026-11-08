require "test_helper"

class PanelControllerTest < ActionDispatch::IntegrationTest
  test "redirige al login si no hay sesión" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "muestra el panel con sesión iniciada" do
    sign_in_as users(:one)

    get root_path

    assert_response :success
  end
end
