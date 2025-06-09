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

    # On wide screens, the essential tabs should be visible
    assert_selector "a", text: "Overview"
    assert_selector "a", text: "Links"
    assert_selector "a", text: "Members"

    # The responsive tabs structure should be in place
    assert_selector "#responsive-tabs-container"
    assert_selector "#overflow-menu", visible: :all
  end

  test "overflow menu appears on narrow screens" do
    # Set a narrow viewport to trigger overflow
    page.driver.browser.manage.window.resize_to(480, 800)

    visit trip_path(@trip)

    # Give JavaScript time to process the resize
    sleep 0.1

    # The JavaScript should detect overflow and show the overflow menu
    # At least one tab should still be visible
    tab_count = all(".tab-item", visible: true).count
    assert tab_count >= 1, "At least one tab should remain visible"

    # Overflow menu should be visible if there are hidden tabs
    hidden_tab_count = all(".tab-item.hidden", visible: false).count
    if hidden_tab_count > 0
      refute_selector "#overflow-menu.hidden"
    end
  end

  test "responsive tabs setup exists" do
    visit trip_path(@trip)

    # Check that the responsive tabs elements are properly set up
    assert_selector "#responsive-tabs-container"
    assert_selector "#visible-tabs-container"
    assert_selector "#overflow-menu", visible: :all

    # Should have at least 3 essential tab items (Overview, Links, Members)
    tab_count = all(".tab-item", visible: :all).count
    assert tab_count >= 3, "Should have at least 3 tabs"
  end
end
