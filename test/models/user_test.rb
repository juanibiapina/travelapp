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

  test "should require name when no account exists" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should not require name when account exists" do
    user = User.new
    account = Account.new(email: "test@example.com", password: "password")
    user.account = account
    assert user.valid?
  end

  test "should create user without account when name is present" do
    user = User.create!(name: "Test User")
    assert user.persisted?
    assert_nil user.account
  end

  test "account? should return true when user has account" do
    user = users(:one) # fixture user with account
    assert user.account?
  end

  test "account? should return false when user has no account" do
    user = User.create!(name: "Test User")
    assert_not user.account?
  end

  test "display_name should return name when present" do
    user = User.create!(name: "Test User")
    assert_equal "Test User", user.display_name
  end

  test "display_name should return account email when name is not present" do
    account = Account.create!(email: "test@example.com", password: "password", user: User.new)
    user = account.user
    user.update!(name: nil)
    assert_equal "test@example.com", user.display_name
  end

  test "display_name should return name even when account exists" do
    user = users(:one) # fixture user with both name and account
    assert_equal user.name, user.display_name
  end
end
