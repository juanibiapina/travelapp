require "test_helper"

class TripMembershipWithoutAccountTest < ActiveSupport::TestCase
  setup do
    @trip_owner = User.create!(email: "owner@example.com", password: "password123")
    @trip = Trip.create!(
      name: "Family Trip",
      start_date: Date.current,
      end_date: Date.current + 7.days
    )
    @trip.add_member(@trip_owner, role: "owner")
  end

  test "should add user without account to trip" do
    user_without_account = User.create!(name: "Child User", has_account: false)

    assert_difference "@trip.members.count", 1 do
      membership = @trip.add_member(user_without_account)
      assert membership.persisted?
      assert_equal "member", membership.role
    end

    assert @trip.member?(user_without_account)
    assert_not @trip.owner?(user_without_account)
  end

  test "should handle all_trips for user without account" do
    user_without_account = User.create!(name: "Child User", has_account: false)

    # Create another trip
    another_trip = Trip.create!(
      name: "Another Trip",
      start_date: Date.current,
      end_date: Date.current + 7.days
    )

    # Add user to both trips
    @trip.add_member(user_without_account)
    another_trip.add_member(user_without_account)

    user_trips = user_without_account.all_trips
    assert_includes user_trips, @trip
    assert_includes user_trips, another_trip
    assert_equal 2, user_trips.count
  end

  test "should allow mixed membership types in same trip" do
    user_with_account = User.create!(email: "member@example.com", password: "password123")
    user_without_account = User.create!(name: "Child Member", has_account: false)

    @trip.add_member(user_with_account)
    @trip.add_member(user_without_account)

    assert_equal 3, @trip.members.count # owner + 2 members
    assert @trip.member?(user_with_account)
    assert @trip.member?(user_without_account)
    assert @trip.owner?(@trip_owner)
  end

  test "should prevent duplicate memberships for users without account" do
    user_without_account = User.create!(name: "Child User", has_account: false)

    # Add user once
    first_membership = @trip.add_member(user_without_account)
    assert first_membership.persisted?

    # Try to add same user again
    second_membership = @trip.add_member(user_without_account)
    assert_equal false, second_membership

    assert_equal 1, @trip.trip_memberships.where(user: user_without_account).count
  end
end
