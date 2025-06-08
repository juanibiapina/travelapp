require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create user without account" do
    user = User.new(name: "John Doe")
    assert user.valid?
    assert user.save
    assert_equal "John Doe", user.name
    assert_not user.has_account?
    assert_nil user.account
  end

  test "should require name for all users" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should create user with account" do
    user = User.create!(name: "User With Account")
    account = Account.create!(user: user, email: "test@example.com", password: "password123")
    
    assert user.has_account?
    assert_equal account, user.account
  end

  test "scope with_account should return only users with accounts" do
    with_account_user = User.create!(name: "With Account")
    Account.create!(user: with_account_user, email: "with@example.com", password: "password123")
    
    without_account_user = User.create!(name: "Without Account")

    users_with_account = User.with_account
    assert_includes users_with_account, with_account_user
    assert_not_includes users_with_account, without_account_user
  end

  test "scope without_account should return only users without accounts" do
    with_account_user = User.create!(name: "With Account")
    Account.create!(user: with_account_user, email: "with@example.com", password: "password123")
    
    without_account_user = User.create!(name: "Without Account")

    users_without_account = User.without_account
    assert_includes users_without_account, without_account_user
    assert_not_includes users_without_account, with_account_user
  end

  test "should return all trips user has access to" do
    user = User.create!(name: "Test User")
    
    # Create trips
    trip1 = Trip.create!(name: "Trip 1", start_date: Date.current, end_date: Date.current + 1.day)
    trip2 = Trip.create!(name: "Trip 2", start_date: Date.current, end_date: Date.current + 1.day)
    trip3 = Trip.create!(name: "Trip 3", start_date: Date.current, end_date: Date.current + 1.day)
    
    # Add user to some trips
    trip1.add_member(user, role: "owner")
    trip2.add_member(user, role: "member")
    # Don't add to trip3
    
    user_trips = user.all_trips
    assert_includes user_trips, trip1
    assert_includes user_trips, trip2
    assert_not_includes user_trips, trip3
    assert_equal 2, user_trips.count
  end

  test "should handle user with no trips" do
    user = User.create!(name: "No Trips User")
    
    user_trips = user.all_trips
    assert_empty user_trips
  end
end