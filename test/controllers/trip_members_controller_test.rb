require "test_helper"

class TripMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    @trip_member = User.create!(name: "Trip Member Without Account")
    @trip.add_member(@trip_member, role: "member")
  end

  test "should redirect to login when not authenticated" do
    get new_trip_member_path(@trip)
    assert_redirected_to new_account_session_path
  end

  test "should get new when authenticated and authorized" do
    sign_in @account
    get new_trip_member_path(@trip)
    assert_response :success
    assert_select "h2", "Add Trip Member"
  end

  test "should create member without account" do
    sign_in @account
    assert_difference("User.count") do
      assert_difference("@trip.trip_memberships.count") do
        post trip_members_path(@trip), params: {
          user: { name: "New Member", picture: "https://example.com/pic.jpg" }
        }
      end
    end
    assert_redirected_to @trip
    assert_equal "Member was successfully added to the trip.", flash[:notice]
  end

  test "should not create member with invalid data" do
    sign_in @account
    assert_no_difference("User.count") do
      post trip_members_path(@trip), params: {
        user: { name: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit for member without account" do
    sign_in @account
    get edit_trip_member_path(@trip, @trip_member)
    assert_response :success
    assert_select "h2", "Edit Trip Member"
  end

  test "should update member without account" do
    sign_in @account
    patch trip_member_path(@trip, @trip_member), params: {
      user: { name: "Updated Name", picture: "https://example.com/new-pic.jpg" }
    }
    assert_redirected_to @trip
    assert_equal "Member was successfully updated.", flash[:notice]
    @trip_member.reload
    assert_equal "Updated Name", @trip_member.name
    assert_equal "https://example.com/new-pic.jpg", @trip_member.picture
  end

  test "should not update member with invalid data" do
    sign_in @account
    patch trip_member_path(@trip, @trip_member), params: {
      user: { name: "" }
    }
    assert_response :unprocessable_entity
  end

  test "should destroy member without account and remove from trip" do
    sign_in @account
    assert_difference("User.count", -1) do
      assert_difference("@trip.trip_memberships.count", -1) do
        delete trip_member_path(@trip, @trip_member)
      end
    end
    assert_redirected_to @trip
    assert_equal "Member was successfully removed from the trip.", flash[:notice]
  end

  test "should not destroy trip owner" do
    sign_in @account
    owner_membership = @trip.trip_memberships.find_by(role: "owner")
    owner = owner_membership.user

    assert_no_difference("User.count") do
      delete trip_member_path(@trip, owner)
    end
    assert_redirected_to @trip
    assert_equal "Cannot remove the trip owner.", flash[:alert]
  end

  test "should not destroy user with account even when removing from trip" do
    # Add a user with account to the trip
    user_with_account = users(:two)
    @trip.add_member(user_with_account, role: "member")

    sign_in @account
    assert_no_difference("User.count") do
      assert_difference("@trip.trip_memberships.count", -1) do
        delete trip_member_path(@trip, user_with_account)
      end
    end
    assert_redirected_to @trip
    assert_equal "Member was successfully removed from the trip.", flash[:notice]
  end

  test "should require trip owner authorization for all actions" do
    # Sign in as a member (not owner) of the trip
    member_account = accounts(:three)
    sign_in member_account

    # Test that member can't access any of the actions
    get new_trip_member_path(@trip)
    assert_response :not_found

    post trip_members_path(@trip), params: { user: { name: "Test" } }
    assert_response :not_found

    get edit_trip_member_path(@trip, @trip_member)
    assert_response :not_found

    patch trip_member_path(@trip, @trip_member), params: { user: { name: "Test" } }
    assert_response :not_found

    delete trip_member_path(@trip, @trip_member)
    assert_response :not_found
  end

  test "should redirect when member not found in trip" do
    sign_in @account
    other_user = User.create!(name: "Other User")

    get edit_trip_member_path(@trip, other_user)
    assert_redirected_to @trip
    assert_equal "Member not found in this trip.", flash[:alert]
  end
end
