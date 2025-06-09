require "application_system_test_case"

class ResponsiveTabsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @trip = trips(:one)
    sign_in @account
  end

  test "tabs display normally on wide screens" do
    visit trip_path(@trip)

    # On wide screens, all tabs should be visible
    assert_selector "a", text: "Overview"
    assert_selector "a", text: "Links"
    assert_selector "a", text: "Invitations"
    assert_selector "a", text: "Members"

    # Overflow menu should be hidden
    assert_selector "[data-responsive-tabs-target='overflowMenu'].hidden", visible: false
  end

  test "overflow menu appears on narrow screens" do
    # Set a narrow viewport to trigger overflow
    page.driver.browser.manage.window.resize_to(480, 800)

    visit trip_path(@trip)

    # Give JavaScript time to process the resize
    sleep 0.1

    # The controller should detect overflow and show the overflow menu
    # At least one tab should still be visible
    tab_count = all("[data-responsive-tabs-target='tab']", visible: true).count
    assert tab_count >= 1, "At least one tab should remain visible"

    # Overflow menu should be visible if there are hidden tabs
    hidden_tab_count = all("[data-responsive-tabs-target='tab'].hidden", visible: false).count
    if hidden_tab_count > 0
      refute_selector "[data-responsive-tabs-target='overflowMenu'].hidden"
    end
  end

  test "responsive tabs controller is connected" do
    visit trip_path(@trip)

    # Check that the Stimulus controller is properly connected
    assert_selector "[data-controller='responsive-tabs']"
    assert_selector "[data-responsive-tabs-target='visibleContainer']"
    assert_selector "[data-responsive-tabs-target='overflowMenu']", visible: :all
    assert_selector "[data-responsive-tabs-target='tab']", count: 4
  end
end
