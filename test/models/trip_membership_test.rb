require "test_helper"

class TripMembershipTest < ActiveSupport::TestCase
  setup do
    @trip = trips(:one)
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should create membership with valid attributes" do
    membership = TripMembership.new(trip: @trip, user: @other_user, role: "member")
    assert membership.valid?
  end

  test "should validate role presence" do
    membership = TripMembership.new(trip: @trip, user: @other_user)
    assert_not membership.valid?
    assert_includes membership.errors[:role], "can't be blank"
  end

  test "should validate uniqueness of user per trip" do
    # First membership
    TripMembership.create!(trip: @trip, user: @other_user, role: "member")

    # Try to create duplicate
    duplicate = TripMembership.new(trip: @trip, user: @other_user, role: "member")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:trip_id], "has already been taken"
  end

  test "should allow different roles" do
    owner = TripMembership.new(trip: @trip, user: @other_user, role: "owner")
    assert owner.valid?
    assert owner.owner?

    member = TripMembership.new(trip: @trip, user: @other_user, role: "member")
    assert member.valid?
    assert member.member?
  end

  test "should accept starting place from same trip" do
    place = Place.create!(
      trip: @trip,
      name: "Starting Location",
      start_date: Date.current + 1.day,
      end_date: Date.current + 3.days
    )
    membership = TripMembership.new(trip: @trip, user: @other_user, role: "member", starting_place: place)
    assert membership.valid?
  end

  test "should reject starting place from different trip" do
    other_trip = trips(:two)
    place = Place.create!(
      trip: other_trip,
      name: "Starting Location",
      start_date: other_trip.start_date + 1.day,
      end_date: other_trip.start_date + 3.days
    )
    membership = TripMembership.new(trip: @trip, user: @other_user, role: "member", starting_place: place)
    assert_not membership.valid?
    assert_includes membership.errors[:starting_place], "must belong to the same trip"
  end

  test "should allow membership without starting place" do
    membership = TripMembership.new(trip: @trip, user: @other_user, role: "member")
    assert membership.valid?
  end

  test "should allow membership with user without account" do
    user_without_account = User.create!(name: "Guest User")
    membership = TripMembership.new(trip: @trip, user: user_without_account, role: "member")
    assert membership.valid?
    assert_nil user_without_account.account
  end

  test "should prevent duplicate users per trip even for users without accounts" do
    user_without_account = User.create!(name: "Guest User")
    TripMembership.create!(trip: @trip, user: user_without_account, role: "member")

    # Try to create duplicate
    duplicate = TripMembership.new(trip: @trip, user: user_without_account, role: "member")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:trip_id], "has already been taken"
  end
end
