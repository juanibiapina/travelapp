require "application_system_test_case"

class TripMembersTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:one)
    @user = @account.user
    @trip = trips(:one)

    # Clear existing memberships to avoid conflicts
    @trip.trip_memberships.destroy_all
    @trip.trip_memberships.create!(user: @user, role: "owner")

    sign_in @account
  end

  test "should remove member without account after fix" do
    # First, add a member without an account
    visit new_trip_trip_member_path(@trip)
    
    fill_in "user_name", with: "Test Member"
    fill_in "user_picture", with: "https://example.com/pic.jpg"
    click_on "Create User"
    
    assert_text "Trip member was successfully added"
    
    # Now try to remove the member
    visit members_trip_path(@trip)
    
    # Find the member we just added
    member_section = find("div.space-y-3")
    member_row = member_section.find("div.text-sm.font-medium", text: "Test Member").ancestor("div.flex.items-center.justify-between")
    
    # For this test, let's disable JavaScript to avoid the confirmation dialog
    # and test the DELETE method directly
    Capybara.current_session.driver.browser.execute_script("window.confirm = function() { return true; };")
    
    # Click the delete button 
    within(member_row) do
      find("button[title='Remove member']").click
    end
    
    # Should be redirected back to members page successfully
    assert_current_path members_trip_path(@trip)
    assert_text "Trip member was successfully removed"
    
    # Member should no longer be visible
    assert_no_text "Test Member"
  end

  test "should add new member without account" do
    visit members_trip_path(@trip)
    
    click_on "Add Member"
    
    fill_in "user_name", with: "New Member"
    fill_in "user_picture", with: "https://example.com/avatar.jpg"
    
    click_on "Create User"
    
    assert_text "Trip member was successfully added"
    assert_text "New Member"
  end

  test "should edit member without account" do
    # Create a member without account first
    member_without_account = User.create!(name: "Editable Member")
    @trip.trip_memberships.create!(user: member_without_account, role: "member")
    
    visit members_trip_path(@trip)
    
    # Find the member and click edit
    find("div", text: "Editable Member").ancestor("div.flex.items-center.justify-between").find("a[title='Edit member']").click
    
    fill_in "user_name", with: "Updated Member Name"
    click_on "Update User"
    
    assert_text "Trip member was successfully updated"
    assert_text "Updated Member Name"
  end
end