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
    click_on "New trip"

    fill_in "Name", with: @trip.name
    fill_in "Start date", with: @trip.start_date
    fill_in "End date", with: @trip.end_date
    click_on "Create Trip"

    assert_text "Trip was successfully created"
    click_on "Back"
  end

  test "should update Trip" do
    visit trip_url(@trip)
    click_on "Edit this trip", match: :first

    fill_in "Name", with: @trip.name
    fill_in "Start date", with: @trip.start_date
    fill_in "End date", with: @trip.end_date
    click_on "Update Trip"

    assert_text "Trip was successfully updated"
    click_on "Back"
  end

  test "should destroy Trip" do
    visit trip_url(@trip)
    click_on "Destroy this trip", match: :first

    assert_text "Trip was successfully destroyed"
  end

  test "should show validation error when end date is before start date" do
    visit trips_url
    click_on "New trip"

    fill_in "Name", with: "Test Trip"
    fill_in "Start date", with: Date.current + 7.days
    fill_in "End date", with: Date.current + 1.day
    click_on "Create Trip"

    assert_text "End date must be after start date"
  end
end
