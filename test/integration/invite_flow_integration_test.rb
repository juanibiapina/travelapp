require "test_helper"

class InviteFlowIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @trip_owner = users(:one)
    @trip = trips(:one)
    @potential_member = users(:two)
  end

  test "complete invite flow: create, share, and accept invite" do
    # Step 1: Trip owner signs in and creates an invite
    sign_in @trip_owner

    # Visit trip page
    get trip_path(@trip)
    assert_response :success

    # Generate an invite link
    assert_difference "Invite.count", 1 do
      post trip_invites_path(@trip)
    end
    assert_redirected_to trip_path(@trip)

    invite = Invite.last
    assert_equal @trip, invite.trip
    assert_equal @trip_owner, invite.created_by
    assert invite.active?
    assert invite.invite_valid?

    # Step 2: User signs out
    sign_out @trip_owner

    # Step 3: Potential member clicks invite link while not signed in
    get accept_invite_path(invite.token)

    # Should redirect to sign in with notice about joining trip
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_match(/Please sign in to join this trip/, response.body)

    # Check that invite token is stored in session
    assert_equal invite.token, session[:pending_invite_token]

    # Step 4: User signs in and then manually accepts the invite
    sign_in @potential_member

    # Manually process the pending invite
    get accept_invite_path(invite.token)

    # Should directly join the trip since user is now signed in
    assert_redirected_to trip_path(@trip)
    follow_redirect!
    assert_match(/Successfully joined the trip/, response.body)

    # Step 5: Verify user is now a member
    assert @trip.member?(@potential_member)
    membership = @trip.trip_memberships.find_by(user: @potential_member)
    assert_not_nil membership
    assert_equal "member", membership.role

    # Step 6: Verify accessing invite again shows they're already a member
    get accept_invite_path(invite.token)
    assert_redirected_to trip_path(@trip)
    follow_redirect!
    assert_match(/You are already a member/, response.body)
  end

  test "invite flow when user is already signed in" do
    # Potential member is already signed in
    sign_in @potential_member

    # Create an invite
    invite = @trip.invites.create!(created_by: @trip_owner)

    # Click invite link
    get accept_invite_path(invite.token)

    # Should directly join the trip
    assert_redirected_to trip_path(@trip)
    follow_redirect!
    assert_match(/Successfully joined the trip/, response.body)

    # Verify membership
    assert @trip.member?(@potential_member)
  end

  test "revoked invite cannot be used" do
    invite = @trip.invites.create!(created_by: @trip_owner)

    # Trip owner revokes the invite
    sign_in @trip_owner
    delete trip_invite_path(@trip, invite)
    assert_redirected_to trip_path(@trip)

    sign_out @trip_owner

    # Potential member tries to use revoked invite
    sign_in @potential_member
    get accept_invite_path(invite.token)

    # Should be rejected
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/expired or been revoked/, response.body)

    # Should not be a member
    assert_not @trip.member?(@potential_member)
  end

  test "expired invite cannot be used" do
    invite = @trip.invites.create!(created_by: @trip_owner, expires_at: 1.hour.ago)

    sign_in @potential_member
    get accept_invite_path(invite.token)

    # Should be rejected
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/expired or been revoked/, response.body)

    # Should not be a member
    assert_not @trip.member?(@potential_member)
  end

  test "invalid invite token shows error" do
    sign_in @potential_member
    get accept_invite_path("invalid_token")

    assert_redirected_to root_path
    follow_redirect!
    assert_match(/Invalid invite link/, response.body)
  end
end
