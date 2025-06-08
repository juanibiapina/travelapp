require "test_helper"

class InvitesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @trip = trips(:one)
    @user = users(:one)
    @account = accounts(:one)
    @invite = invites(:one)
    sign_in @account
  end

  test "should create invite" do
    assert_difference("Invite.count") do
      post trip_invites_url(@trip)
    end

    assert_redirected_to trip_invites_url(@trip)
    assert_equal @user, Invite.last.created_by
  end

  test "should revoke invite" do
    # Invite should start as active
    assert @invite.active?
    assert @invite.invite_valid?

    delete trip_invite_url(@trip, @invite)

    # Should be revoked but not destroyed
    assert_redirected_to trip_invites_url(@trip)
    @invite.reload
    assert_not @invite.active?
    assert_not @invite.invite_valid?
  end

  test "should accept valid invite when signed in" do
    sign_in accounts(:two) # Different user

    get accept_invite_url(@invite.token)

    assert_redirected_to trip_url(@invite.trip)
    assert @invite.trip.member?(users(:two))
  end

  test "should redirect to sign in when not signed in" do
    sign_out @account

    get accept_invite_url(@invite.token)

    assert_redirected_to new_account_session_url
  end

  test "should handle invalid invite token" do
    get accept_invite_url("invalid_token")

    assert_redirected_to root_url
  end
end
