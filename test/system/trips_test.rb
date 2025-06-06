require "application_system_test_case"

class TripsTest < ApplicationSystemTestCase
  setup do
    @trip = trips(:one)
    @user = users(:one)
    sign_in @user
  end

  test "visiting the index" do
    visit trips_url
    assert_selector "h1", text: "Trips"
  end

  test "should create trip" do
    visit trips_url
    click_on "New Trip"

    fill_in "Name", with: @trip.name
    click_on "Create Trip"

    assert_text "Trip was successfully created"
    click_on "Back"
  end

  test "should update Trip" do
    visit trip_url(@trip)
    click_on "Edit Trip", match: :first

    fill_in "Name", with: @trip.name
    click_on "Update Trip"

    assert_text "Trip was successfully updated"
    click_on "Back"
  end

  test "should destroy Trip" do
    visit trip_url(@trip)
    click_on "Delete Trip", match: :first

    assert_text "Trip was successfully destroyed"
  end
end
