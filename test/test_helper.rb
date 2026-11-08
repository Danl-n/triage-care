ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Las pruebas corren en secuencia: Windows no permite paralelizar con procesos (fork) y,
    # con hilos, las pruebas que inician sesión (Current) y el autoload se interfieren entre sí.

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
