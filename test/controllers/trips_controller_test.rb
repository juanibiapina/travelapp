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
      post trips_url, params: { trip: { name: @trip.name } }
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
    patch trip_url(@trip), params: { trip: { name: @trip.name } }
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
end
