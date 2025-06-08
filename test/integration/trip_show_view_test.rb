require "test_helper"

class TripShowViewTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @trip_owner = users(:one)
    @trip_owner_account = accounts(:one)
    @trip = trips(:one)
    @member = users(:two)
    @member_account = accounts(:two)

    sign_in @trip_owner_account
  end

  test "trip show page displays invite section for owners" do
    # Clear any existing invites first
    @trip.invites.destroy_all

    # Go to the invitations tab
    get trip_invites_path(@trip)
    assert_response :success

    # Should show invite section
    assert_select "h2", text: "Invite Links"
    assert_select "button", text: "Generate New Link"
    # Check for the exact text in the view when no invites exist
    assert_match(/No active invite links/, response.body)
  end

  test "trip show page displays active invites" do
    invite = @trip.invites.create!(created_by: @trip_owner)

    # Go to the invitations tab
    get trip_invites_path(@trip)
    assert_response :success

    # Should show the invite
    assert_select "input[value*='#{accept_invite_url(invite.token)}']"
    assert_select "button", text: "Copy"
    assert_select "button", text: "Revoke"
  end

  test "member can view trip but cannot see invite section" do
    # Add the member to the trip
    @trip.add_member(@member)

    sign_out @trip_owner_account
    sign_in @member_account

    # Go to the invitations tab
    get trip_invites_path(@trip)
    assert_response :success

    # Should not show invite section (generate button won't be there for non-owners)
    assert_select "button", text: "Generate New Link", count: 0
  end

  test "trip show page displays members section" do
    # Go to the members tab
    get members_trip_path(@trip)
    assert_response :success

    # Should show members section
    assert_select "h2", text: "Trip Members"

    # Should display the owner (user one)
    assert_match(/User One/, response.body)
    assert_match(/Owner/, response.body)

    # Should display the member (user three from fixtures)
    assert_match(/User Three/, response.body)
    assert_match(/Member/, response.body)
  end
end
