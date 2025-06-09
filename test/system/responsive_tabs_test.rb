require "application_system_test_case"

class ResponsiveTabsTest < ApplicationSystemTestCase
  setup do
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "responsive tabs are displayed correctly on large screens" do
    visit trip_url(@trip)

    # All tabs should be visible in the main container
    assert_selector "[data-responsive-tabs-target='tab']", count: 4
    assert_text "Overview"
    assert_text "Links"
    assert_text "Invitations"
    assert_text "Members"

    # Overflow button should be hidden on large screens
    assert_selector "[data-responsive-tabs-target='overflowButton'].hidden", visible: false
  end

  test "responsive tabs container has correct structure" do
    visit trip_url(@trip)

    # Check that the responsive tabs controller is present
    assert_selector "[data-controller='responsive-tabs']"
    
    # Check that required targets are present
    assert_selector "[data-responsive-tabs-target='container']"
    assert_selector "[data-responsive-tabs-target='overflowButton']", visible: false
    assert_selector "[data-responsive-tabs-target='overflowMenu']", visible: false
    
    # Check tab targets
    assert_selector "[data-responsive-tabs-target='tab']", minimum: 1
  end

  test "tab navigation still works correctly" do
    visit trip_url(@trip)

    # Click on Links tab
    click_on "Links"
    assert_current_path trip_links_path(@trip)

    # Go back to trip and click on Members tab
    visit trip_url(@trip)
    click_on "Members"
    assert_current_path members_trip_path(@trip)
  end
end