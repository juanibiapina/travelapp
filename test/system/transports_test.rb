require "application_system_test_case"

class TransportsTest < ApplicationSystemTestCase
  setup do
    @transport = transports(:one)
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "visiting the index" do
    visit trip_transports_url(@trip)
    assert_selector "h2", text: "Transport"
    assert_selector "p", text: "Manage transportation between places during your trip"
  end

  test "should create transport" do
    visit trip_transports_url(@trip)
    click_on "Add New Transport"

    fill_in "Name", with: "Test Flight"
    fill_in "Start date", with: Date.current
    fill_in "End date", with: Date.current
    select "Eiffel Tower", from: "Origin Place"
    select "Notre Dame", from: "Destination Place"
    click_on "Create Transport"

    assert_text "Transport was successfully created"
    assert_text "Test Flight"
  end

  test "should show transport" do
    visit trip_transport_url(@trip, @transport)
    assert_selector "h1", text: @transport.name
    assert_text @transport.origin_place.name
    assert_text @transport.destination_place.name
  end

  test "should update transport" do
    visit trip_transport_url(@trip, @transport)
    click_on "Edit"

    fill_in "Name", with: "Updated Flight"
    click_on "Update Transport"

    assert_text "Transport was successfully updated"
    assert_text "Updated Flight"
  end

  test "should destroy transport" do
    visit trip_transports_url(@trip)
    page.accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Transport was successfully destroyed"
  end

  test "transport tab appears in navigation" do
    visit trip_url(@trip)
    assert_selector "nav a", text: "Transport"
  end

  test "transport tab shows count" do
    visit trip_url(@trip)
    # Should show the count of transports for the trip
    assert_selector "nav a", text: /Transport.*2/m
  end

  test "empty state is shown when no transports exist" do
    # Remove all transports from the trip
    @trip.transports.destroy_all

    visit trip_transports_url(@trip)
    assert_text "No transport added yet"
    assert_text "Add flights, trains, buses, or other transportation"
    assert_selector "a", text: "Add Your First Transport"
  end
end
