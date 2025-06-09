require "application_system_test_case"

class DrawerTest < ApplicationSystemTestCase
  setup do
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "can open and close the drawer overlay" do
    visit trip_url(@trip)

    # Open the drawer
    find('button[aria-label="Open menu"]').click
    assert_selector 'aside[data-drawer-target="panel"]', visible: true
    assert_selector 'div[data-drawer-target="overlay"]', visible: true

    # Close the drawer with the close button
    find('button[aria-label="Close menu"]').click
    assert_no_selector 'aside[data-drawer-target="panel"]', visible: true
    assert_no_selector 'div[data-drawer-target="overlay"]', visible: true
  end
end
