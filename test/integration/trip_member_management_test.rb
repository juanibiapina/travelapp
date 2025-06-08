require "test_helper"

class TripMemberManagementTest < ActionDispatch::IntegrationTest
  setup do
    @trip = trips(:one)
    @owner_account = accounts(:one) # User One owns Trip One
    @member_account = accounts(:three) # User Three is a member of Trip One
    @non_account_member = users(:four) # User Four is a member without account
  end

  test "trip owner can add a member without account" do
    sign_in @owner_account
    get trip_path(@trip)
    assert_response :success

    # Should see "Add Member" button
    assert_select "a[href=?]", new_trip_member_path(@trip), text: "Add Member"

    # Go to new member form
    get new_trip_member_path(@trip)
    assert_response :success
    assert_select "h2", "Add Trip Member"

    # Create a new member
    assert_difference "User.count", 1 do
      assert_difference "@trip.trip_memberships.count", 1 do
        post trip_members_path(@trip), params: {
          user: { name: "New Child Member", picture: "https://example.com/new-child.jpg" }
        }
      end
    end

    follow_redirect!
    assert_equal trip_path(@trip), path
    assert_match "Member was successfully added to the trip", flash[:notice]

    # Verify the new member appears in the members list
    new_member = User.find_by(name: "New Child Member")
    assert new_member.present?
    assert_not new_member.account?
    assert @trip.member?(new_member)
  end

  test "trip owner can edit member without account" do
    sign_in @owner_account
    get trip_path(@trip)
    assert_response :success

    # Should see Edit button for non-account member
    assert_select "a[href=?]", edit_trip_member_path(@trip, @non_account_member), text: "Edit"

    # Go to edit form
    get edit_trip_member_path(@trip, @non_account_member)
    assert_response :success
    assert_select "h2", "Edit Trip Member"

    # Update the member
    patch trip_member_path(@trip, @non_account_member), params: {
      user: { name: "Updated Child Name", picture: "https://example.com/updated-pic.jpg" }
    }

    follow_redirect!
    assert_equal trip_path(@trip), path
    assert_match "Member was successfully updated", flash[:notice]

    # Verify the changes
    @non_account_member.reload
    assert_equal "Updated Child Name", @non_account_member.name
    assert_equal "https://example.com/updated-pic.jpg", @non_account_member.picture
  end

  test "trip owner can remove member without account" do
    sign_in @owner_account
    get trip_path(@trip)
    assert_response :success

    # Should see Remove button for non-account member
    assert_select "form[action=?][method=?]", trip_member_path(@trip, @non_account_member), "post" do
      assert_select "input[type=hidden][name=_method][value=delete]"
      assert_select "button[type=submit]", text: "Remove"
    end

    # Remove the member
    assert_difference "User.count", -1 do
      assert_difference "@trip.trip_memberships.count", -1 do
        delete trip_member_path(@trip, @non_account_member)
      end
    end

    follow_redirect!
    assert_equal trip_path(@trip), path
    assert_match "Member was successfully removed from the trip", flash[:notice]

    # Verify the member is gone
    assert_not User.exists?(@non_account_member.id)
    assert_not @trip.member?(@non_account_member)
  end

  test "trip owner cannot edit/remove members with accounts" do
    sign_in @owner_account
    get trip_path(@trip)
    assert_response :success

    # Should NOT see Edit/Remove buttons for account members
    assert_select "a[href=?]", edit_trip_member_path(@trip, users(:three)), { count: 0 }
    assert_select "form[action=?]", trip_member_path(@trip, users(:three)), { count: 0 }
  end

  test "trip member cannot access member management" do
    sign_in @member_account

    # Cannot access new member form
    get new_trip_member_path(@trip)
    assert_response :not_found

    # Cannot create members
    post trip_members_path(@trip), params: { user: { name: "Test" } }
    assert_response :not_found

    # Cannot edit members
    get edit_trip_member_path(@trip, @non_account_member)
    assert_response :not_found

    # Cannot update members
    patch trip_member_path(@trip, @non_account_member), params: { user: { name: "Test" } }
    assert_response :not_found

    # Cannot delete members
    delete trip_member_path(@trip, @non_account_member)
    assert_response :not_found
  end

  test "member display shows correct information" do
    sign_in @owner_account
    get trip_path(@trip)
    assert_response :success

    # Check that account member shows name from user record
    account_member = users(:three)
    assert_select "div", text: account_member.display_name

    # Check that non-account member shows name and "No account" indicator
    assert_select "div", text: @non_account_member.display_name
    assert_select "div", text: "No account"

    # There should be exactly one "No account" indicator (for user four only)
    assert_select "div", text: "No account", count: 1
  end

  test "displays add member button only for trip owners" do
    # Owner should see the button
    sign_in @owner_account
    get trip_path(@trip)
    assert_response :success
    assert_select "a[href=?]", new_trip_member_path(@trip), text: "Add Member"

    # Member should not see the button
    sign_in @member_account
    get trip_path(@trip)
    assert_response :success
    assert_select "a[href=?]", new_trip_member_path(@trip), { count: 0 }
  end
end
