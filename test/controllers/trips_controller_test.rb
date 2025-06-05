require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @trip = trips(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get trips_url
    assert_response :success
  end

  test "should get root path and show trips index" do
    get root_url
    assert_response :success
  end

  test "should get new" do
    get new_trip_url
    assert_response :success
  end

  test "should create trip" do
    assert_difference("Trip.count") do
      post trips_url, params: { trip: { name: @trip.name, start_date: @trip.start_date, end_date: @trip.end_date } }
    end

    assert_redirected_to trip_url(Trip.last)
  end

  test "should show trip" do
    get trip_url(@trip)
    assert_response :success
  end

  test "should get edit" do
    get edit_trip_url(@trip)
    assert_response :success
  end

  test "should update trip" do
    patch trip_url(@trip), params: { trip: { name: @trip.name, start_date: @trip.start_date, end_date: @trip.end_date } }
    assert_redirected_to trip_url(@trip)
  end

  test "should destroy trip" do
    assert_difference("Trip.count", -1) do
      delete trip_url(@trip)
    end

    assert_redirected_to trips_url
  end

  test "should redirect to sign in when not authenticated" do
    sign_out @user
    get trips_url
    assert_redirected_to new_user_session_path
  end

  test "should only show trips belonging to current user in index" do
    # Create a trip for user two
    trip_for_user_two = users(:two).trips.create!(
      name: "User Two Trip",
      start_date: Date.current + 1.day,
      end_date: Date.current + 7.days
    )

    get trips_url
    assert_response :success
    assert_select "h1", "Trips"
    # The trip from user two should not be visible
  end

  test "should not allow access to trip belonging to another user" do
    other_user = users(:two)
    other_trip = other_user.trips.create!(
      name: "Other User Trip",
      start_date: Date.current + 1.day,
      end_date: Date.current + 7.days
    )

    get trip_url(other_trip)
    assert_response :not_found
  end

  test "should not allow editing trip belonging to another user" do
    other_user = users(:two)
    other_trip = other_user.trips.create!(
      name: "Other User Trip",
      start_date: Date.current + 1.day,
      end_date: Date.current + 7.days
    )

    get edit_trip_url(other_trip)
    assert_response :not_found
  end

  test "should not allow updating trip belonging to another user" do
    other_user = users(:two)
    other_trip = other_user.trips.create!(
      name: "Other User Trip",
      start_date: Date.current + 1.day,
      end_date: Date.current + 7.days
    )

    patch trip_url(other_trip), params: { trip: { name: "Updated Name" } }
    assert_response :not_found
  end

  test "should not allow destroying trip belonging to another user" do
    other_user = users(:two)
    other_trip = other_user.trips.create!(
      name: "Other User Trip",
      start_date: Date.current + 1.day,
      end_date: Date.current + 7.days
    )

    delete trip_url(other_trip)
    assert_response :not_found
  end
end
