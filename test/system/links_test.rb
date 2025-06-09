require "application_system_test_case"

class LinksTest < ApplicationSystemTestCase
  setup do
    @link = links(:one)
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "visiting the index" do
    visit trip_links_url(@trip)
    assert_selector "h2", text: "Useful Links"
  end

  test "should create link" do
    visit trip_links_url(@trip)
    click_on "Add New Link"

    fill_in "Url", with: @link.url
    click_on "Create Link"

    assert_text "Link was successfully created"
    # Navigate back using the main navigation
    visit trips_url
  end

  test "should update Link" do
    visit trip_link_url(@trip, @link)
    click_on "Edit this link", match: :first

    fill_in "Url", with: @link.url
    click_on "Update Link"

    assert_text "Link was successfully updated"
    click_on "Back to trip"
  end

  test "should destroy Link" do
    visit trip_link_url(@trip, @link)

    # Accept the confirmation dialog when clicking destroy
    accept_confirm do
      click_on "Destroy this link", match: :first
    end

    assert_text "Link was successfully destroyed"
  end
end
