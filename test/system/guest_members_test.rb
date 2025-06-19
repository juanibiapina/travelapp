require "application_system_test_case"

class GuestMembersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    sign_in @account
  end

  test "adding a guest member" do
    visit members_trip_path(@trip)

    # Should see the add guest member form
    assert_text "Add Member Without Account"

    # Fill in the form
    fill_in "Name", with: "Child Member"
    fill_in "Picture URL (optional)", with: "http://example.com/child.jpg"

    # Submit the form
    click_button "Add Member"

    # Should redirect back to members page with success message
    assert_text "Member added successfully"
    assert_text "Child Member"
    assert_text "Guest" # Should show guest badge
  end

  test "editing a guest member" do
    # Create a guest user first
    guest_user = User.create!(name: "Guest User")
    @trip.add_member(guest_user)

    visit members_trip_path(@trip)

    # Should see the guest member
    assert_text "Guest User"
    assert_text "Guest"

    # Click edit button (pencil icon)
    within("[data-testid='member-#{guest_user.id}']") do
      find("button[title='Edit member']").click
    end

    # Should show edit form - fill it within the specific edit form container
    within("#edit-member-#{@trip.trip_memberships.find_by(user: guest_user).id}") do
      fill_in "user_name", with: "Updated Guest"
      fill_in "user_picture", with: "http://example.com/updated.jpg"
      click_button "Update"
    end

    # Should see updated information
    assert_text "Member updated successfully"
    assert_text "Updated Guest"
  end

  test "deleting a guest member" do
    # Create a guest user first
    guest_user = User.create!(name: "Guest User")
    @trip.add_member(guest_user)

    visit members_trip_path(@trip)

    # Should see the guest member
    assert_text "Guest User"

    # Should have delete functionality available for guest members
    within("[data-testid='member-#{guest_user.id}']") do
      assert_selector "button[title='Remove member']"
    end
  end

  test "cannot edit or delete regular members" do
    visit members_trip_path(@trip)

    # Should see regular member but no edit/delete buttons for them
    assert_text @user.name
    within("[data-testid='member-#{@user.id}']") do
      assert_no_text "Edit member" # Since this user has an account
    end
  end
end
