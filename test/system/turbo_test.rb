require "application_system_test_case"

class TurboTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "turbo javascript is loaded" do
    visit root_url

    # Check that Turbo JavaScript modules are available
    turbo_loaded = page.evaluate_script("typeof Turbo !== 'undefined'")
    assert turbo_loaded, "Turbo should be loaded and available"
  end

  test "page navigation works with turbo" do
    visit root_url

    # Check that the home page loads
    assert_text "Rails Template"

    # Navigate to sign out (this uses Turbo)
    find("button[aria-label='User menu']").click
    click_on "Sign out"

    # Should redirect to home page and show sign in links
    assert_text "Get Started"
    assert_selector "a", text: "Sign In"
  end
end
