require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  test "controller inherits from Devise::OmniauthCallbacksController" do
    assert Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  end
end
