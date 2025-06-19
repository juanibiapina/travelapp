require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
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
      post trips_url, params: { trip: { name: @trip.name, start_date: Date.current, end_date: Date.current + 7.days } }
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
    sign_out @account
    get trips_url
    assert_redirected_to new_account_session_path
  end

  test "should only show trips belonging to current user in index" do
    # Create a trip for user two
    trip_for_user_two = create_trip_with_owner("User Two Trip", users(:two))

    get trips_url
    assert_response :success
    assert_select "h1", "Your Trips"
    # The trip from user two should not be visible
  end

  test "should not allow access to trip belonging to another user" do
    other_user = users(:two)
    other_trip = create_trip_with_owner("Other User Trip", other_user)

    get trip_url(other_trip)
    assert_response :not_found
  end

  test "should not allow editing trip belonging to another user" do
    other_user = users(:two)
    other_trip = create_trip_with_owner("Other User Trip", other_user)

    get edit_trip_url(other_trip)
    assert_response :not_found
  end

  test "should not allow updating trip belonging to another user" do
    other_user = users(:two)
    other_trip = create_trip_with_owner("Other User Trip", other_user)

    patch trip_url(other_trip), params: { trip: { name: "Updated Name" } }
    assert_response :not_found
  end

  test "should not allow destroying trip belonging to another user" do
    other_user = users(:two)
    other_trip = create_trip_with_owner("Other User Trip", other_user)

    delete trip_url(other_trip)
    assert_response :not_found
  end

  test "should get members" do
    get members_trip_url(@trip)
    assert_response :success
    assert_select "h2", "Trip Members"
  end

  test "should update member starting place" do
    membership = @trip.trip_memberships.first
    place = Place.create!(
      trip: @trip,
      name: "Airport",
      start_date: Date.current + 1.day,
      end_date: Date.current + 3.days
    )

    patch update_member_starting_place_trip_url(@trip), params: {
      membership_id: membership.id,
      starting_place_id: place.id
    }

    assert_redirected_to members_trip_url(@trip)
    assert_equal place, membership.reload.starting_place
  end

  test "should clear member starting place" do
    place = Place.create!(
      trip: @trip,
      name: "Airport",
      start_date: Date.current + 1.day,
      end_date: Date.current + 3.days
    )
    membership = @trip.trip_memberships.first
    membership.update!(starting_place: place)

    patch update_member_starting_place_trip_url(@trip), params: {
      membership_id: membership.id,
      starting_place_id: ""
    }

    assert_redirected_to members_trip_url(@trip)
    assert_nil membership.reload.starting_place
  end

  test "should create member without account" do
    assert_difference([ "User.count", "TripMembership.count" ], 1) do
      post create_guest_member_trip_url(@trip), params: {
        user: { name: "Child Member", picture: "http://example.com/child.jpg" }
      }
    end

    assert_redirected_to members_trip_url(@trip)
    new_user = User.last
    assert_equal "Child Member", new_user.name
    assert_equal "http://example.com/child.jpg", new_user.picture
    assert_nil new_user.account
    assert @trip.member?(new_user)
  end

  test "should not create member without account when missing name" do
    assert_no_difference([ "User.count", "TripMembership.count" ]) do
      post create_guest_member_trip_url(@trip), params: {
        user: { name: "", picture: "http://example.com/pic.jpg" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should update guest member" do
    guest_user = User.create!(name: "Guest")
    @trip.add_member(guest_user)
    membership = @trip.trip_memberships.find_by(user: guest_user)

    patch update_guest_member_trip_url(@trip), params: {
      membership_id: membership.id,
      user: { name: "Updated Guest", picture: "http://example.com/new.jpg" }
    }

    assert_redirected_to members_trip_url(@trip)
    guest_user.reload
    assert_equal "Updated Guest", guest_user.name
    assert_equal "http://example.com/new.jpg", guest_user.picture
  end

  test "should delete guest member" do
    guest_user = User.create!(name: "Guest")
    @trip.add_member(guest_user)
    membership = @trip.trip_memberships.find_by(user: guest_user)

    assert_difference([ "User.count", "TripMembership.count" ], -1) do
      delete destroy_guest_member_trip_url(@trip), params: { membership_id: membership.id }
    end

    assert_redirected_to members_trip_url(@trip)
  end

  test "should not allow deleting member with account" do
    membership = @trip.trip_memberships.find_by(user: @user)

    assert_no_difference([ "User.count", "TripMembership.count" ]) do
      delete destroy_guest_member_trip_url(@trip), params: { membership_id: membership.id }
    end

    assert_response :unprocessable_entity
  end

  private

  def create_trip_with_owner(name, user)
    trip = Trip.create!(name: name, start_date: Date.current, end_date: Date.current + 7.days)
    TripMembership.create!(trip: trip, user: user, role: "owner")
    trip
  end
end
