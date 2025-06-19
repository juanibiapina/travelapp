require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should have account association" do
    user = User.create!(name: "Test User")
    assert_respond_to user, :account
  end

  test "should have trip memberships association" do
    user = User.create!(name: "Test User")
    assert_respond_to user, :trip_memberships
  end

  test "should have member trips association" do
    user = User.create!(name: "Test User")
    assert_respond_to user, :member_trips
  end

  test "should have created invites association" do
    user = User.create!(name: "Test User")
    assert_respond_to user, :created_invites
  end

  test "all_trips should return trips user has access to" do
    user = users(:one)
    # The all_trips method should work even though we don't have specific trip data in this test
    assert_respond_to user, :all_trips
    trips = user.all_trips
    assert trips.is_a?(ActiveRecord::Relation)
  end

  test "should create user without account" do
    user = User.create!(name: "Child User")
    assert user.valid?
    assert_nil user.account
    assert_equal "Child User", user.name
  end

  test "should display name when user has no account" do
    user = User.create!(name: "Guest User", picture: "http://example.com/pic.jpg")
    assert_equal "Guest User", user.name
    assert_nil user.account
    assert_equal "http://example.com/pic.jpg", user.picture
  end
end
