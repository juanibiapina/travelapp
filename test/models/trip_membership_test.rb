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
end
