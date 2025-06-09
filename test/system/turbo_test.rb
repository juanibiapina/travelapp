require "application_system_test_case"

class TurboTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "turbo javascript is loaded" do
    visit trips_url

    # Check that Turbo JavaScript modules are available
    turbo_loaded = page.evaluate_script("typeof Turbo !== 'undefined'")
    assert turbo_loaded, "Turbo should be loaded and available"
  end

  test "forms work with turbo" do
    visit trips_url
    click_on "New Trip"

    # Fill in the form
    fill_in "trip_name", with: "Turbo Test Trip"
    fill_in "trip_start_date", with: Date.current
    fill_in "trip_end_date", with: Date.current + 7.days

    # Submit should work via Turbo (AJAX)
    click_on "Create Trip"

    # Should see success message
    assert_text "Trip was successfully created"

    # Should be on the trip show page
    assert_text "Turbo Test Trip"
  end
end
