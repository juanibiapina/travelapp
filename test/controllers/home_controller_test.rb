require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "h1", text: "Rails Template"
  end

  test "should show sign in links when not authenticated" do
    get root_url
    assert_response :success
    assert_select "a[href=?]", new_account_registration_path
    assert_select "a[href=?]", new_account_session_path
  end

  test "should show welcome message when authenticated" do
    account = accounts(:one)
    sign_in account

    get root_url
    assert_response :success
    assert_select "h3", text: /Welcome back/
    assert_select "a[href=?]", destroy_account_session_path
  end
end
