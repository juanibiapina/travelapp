require "application_system_test_case"

class AccommodationsTest < ApplicationSystemTestCase
  setup do
    @accommodation = accommodations(:one)
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "visiting the index" do
    visit trip_accommodations_url(@trip)
    assert_selector "h2", text: "Accommodations"
  end

  test "should create accommodation with place selection" do
    visit trip_accommodations_url(@trip)
    click_on "Add New Accommodation"

    fill_in "Title", with: "Test Hotel"
    fill_in "Check-in Date", with: Date.current
    fill_in "Check-out Date", with: Date.current + 1.day
    select "Eiffel Tower", from: "Place"
    click_on "Create Accommodation"

    assert_text "Accommodation was successfully created"
    assert_text "Test Hotel"
  end

  test "should update accommodation" do
    visit trip_accommodation_url(@trip, @accommodation)
    click_on "Edit"

    fill_in "Title", with: "Updated Hotel"
    click_on "Update Accommodation"

    assert_text "Accommodation was successfully updated"
    assert_text "Updated Hotel"
  end

  test "should destroy accommodation" do
    visit trip_accommodation_url(@trip, @accommodation)
    accept_alert do
      click_on "Delete", match: :first
    end

    assert_text "Accommodation was successfully deleted"
  end
end
