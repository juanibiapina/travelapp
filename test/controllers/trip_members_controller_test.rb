require "test_helper"

class TripMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @user = @account.user
    @trip = trips(:one)

    # Clear existing memberships to avoid conflicts
    @trip.trip_memberships.destroy_all
    @trip.trip_memberships.create!(user: @user, role: "owner")

    # Create a user without an account for testing
    @member_without_account = User.create!(name: "Test Member")
    @membership = @trip.trip_memberships.create!(user: @member_without_account, role: "member")
  end

  test "should get new when authorized" do
    sign_in @account
    get new_trip_trip_member_url(@trip)
    assert_response :success
  end

  test "should create trip member" do
    sign_in @account
    assert_difference("User.count") do
      assert_difference("TripMembership.count") do
        post trip_trip_members_url(@trip), params: {
          user: { name: "New Member", picture: "https://example.com/pic.jpg" }
        }
      end
    end

    assert_redirected_to members_trip_url(@trip)
    new_user = User.find_by(name: "New Member")
    assert new_user
    assert_equal "https://example.com/pic.jpg", new_user.picture
    assert @trip.member?(new_user)
  end

  test "should not create trip member with invalid data" do
    sign_in @account
    assert_no_difference("User.count") do
      post trip_trip_members_url(@trip), params: { user: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit when authorized" do
    sign_in @account
    get edit_trip_trip_member_url(@trip, @member_without_account)
    assert_response :success
  end

  test "should update trip member" do
    sign_in @account
    patch trip_trip_member_url(@trip, @member_without_account), params: {
      user: { name: "Updated Name", picture: "https://example.com/new.jpg" }
    }
    assert_redirected_to members_trip_url(@trip)

    @member_without_account.reload
    assert_equal "Updated Name", @member_without_account.name
    assert_equal "https://example.com/new.jpg", @member_without_account.picture
  end

  test "should destroy trip member without account" do
    sign_in @account
    assert_difference("User.count", -1) do
      assert_difference("TripMembership.count", -1) do
        delete trip_trip_member_url(@trip, @member_without_account)
      end
    end
    assert_redirected_to members_trip_url(@trip)
  end

  test "should not destroy trip owner" do
    sign_in @account
    assert_no_difference("User.count") do
      delete trip_trip_member_url(@trip, @user)
    end
    assert_redirected_to members_trip_url(@trip)
    assert_match /cannot remove the trip owner/i, flash[:alert]
  end

  test "should require authentication" do
    get new_trip_trip_member_url(@trip)
    assert_redirected_to new_account_session_url
  end

  test "should require authorization" do
    # Create another user who is not a member of the trip
    other_user = User.create!(name: "Other User")
    other_account = Account.create!(email: "other@example.com", password: "password", user: other_user)

    sign_in other_account
    get new_trip_trip_member_url(@trip)
    assert_response :not_found
  end
end
