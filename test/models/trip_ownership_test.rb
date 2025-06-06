require "test_helper"

class TripOwnershipTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test "trip owner should be determined by membership table when both systems present" do
    # Create a trip and add owner membership
    trip = Trip.create!(name: "Test Trip", start_date: Date.current, end_date: Date.current + 7.days)

    # Add owner membership
    TripMembership.create!(trip: trip, user: @user, role: "owner")

    # The owner should be determined by membership
    assert_equal @user, trip.owner
    assert trip.owner?(@user)
    assert_not trip.owner?(@other_user)
  end

  test "trip membership should be determined by membership table only" do
    # Create a trip
    trip = Trip.create!(name: "Test Trip", start_date: Date.current, end_date: Date.current + 7.days)

    # Add member membership for other user
    TripMembership.create!(trip: trip, user: @other_user, role: "member")

    # Only membership users should be members
    assert_not trip.member?(@user)  # User without membership is not a member
    assert trip.member?(@other_user)  # Membership user is a member

    # Neither should be owner since no owner membership exists
    assert_not trip.owner?(@user)
    assert_not trip.owner?(@other_user)
  end

  test "user all_trips should work with membership table only" do
    # Create trips using membership system
    trip1 = Trip.create!(name: "Owned Trip", start_date: Date.current, end_date: Date.current + 7.days)
    TripMembership.create!(trip: trip1, user: @user, role: "owner")

    trip2 = Trip.create!(name: "Member Trip", start_date: Date.current + 1.month, end_date: Date.current + 1.month + 7.days)
    TripMembership.create!(trip: trip2, user: @user, role: "member")

    trip3 = Trip.create!(name: "Not Accessible Trip", start_date: Date.current + 2.months, end_date: Date.current + 2.months + 7.days)
    TripMembership.create!(trip: trip3, user: @other_user, role: "owner")

    # User should have access to trips they have memberships for
    user_trips = @user.all_trips
    assert_includes user_trips, trip1
    assert_includes user_trips, trip2
    assert_not_includes user_trips, trip3
  end
end
