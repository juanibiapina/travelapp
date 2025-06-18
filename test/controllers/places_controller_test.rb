require "test_helper"

class PlacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @trip = trips(:one)
    @place = places(:five) # Use an unused place that can be safely deleted
    sign_in @account
  end

  test "should get index" do
    get trip_places_url(@trip)
    assert_response :success
  end

  test "should get new" do
    get new_trip_place_url(@trip)
    assert_response :success
  end

  test "should create place" do
    assert_difference("Place.count") do
      post trip_places_url(@trip), params: { place: { name: "Notre Dame" } }
    end

    assert_redirected_to trip_places_url(@trip)
  end

  test "should not create place with blank name" do
    assert_no_difference("Place.count") do
      post trip_places_url(@trip), params: { place: { name: "" } }
    end

    assert_redirected_to trip_places_url(@trip)
    follow_redirect!
    assert_select ".bg-red-100", text: /can't be blank/
  end

  test "should show place" do
    get trip_place_url(@trip, @place)
    assert_response :success
  end

  test "should get edit" do
    get edit_trip_place_url(@trip, @place)
    assert_response :success
  end

  test "should update place" do
    patch trip_place_url(@trip, @place), params: { place: { name: "Updated Place Name" } }
    assert_redirected_to trip_place_url(@trip, @place)
  end

  test "should destroy place" do
    assert_difference("Place.count", -1) do
      delete trip_place_url(@trip, @place)
    end

    assert_redirected_to trip_places_url(@trip)
  end

  test "should require authentication" do
    sign_out @account
    get trip_places_url(@trip)
    assert_redirected_to new_account_session_path
  end

  test "should require trip membership for index" do
    # User one is not a member of trip two
    other_trip = trips(:two)
    get trip_places_url(other_trip)
    assert_response :not_found
  end

  test "should require trip ownership for create" do
    # User one is only a member (not owner) of trip one via membership three
    # But user one is the owner of trip one via membership one
    # Let's use a different approach - make user one just a member
    @trip.trip_memberships.find_by(user: @user, role: "owner").destroy!
    @trip.trip_memberships.create!(user: @user, role: "member")

    assert_no_difference("Place.count") do
      post trip_places_url(@trip), params: { place: { name: "Test Place" } }
    end
    assert_response :not_found
  end
end
