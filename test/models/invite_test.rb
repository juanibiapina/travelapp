require "test_helper"

class InviteTest < ActiveSupport::TestCase
  setup do
    @trip = trips(:one)
    @user = users(:one)
  end

  test "should generate unique token on creation" do
    invite1 = @trip.invites.create!(created_by: @user)
    invite2 = @trip.invites.create!(created_by: @user)

    assert_not_nil invite1.token
    assert_not_nil invite2.token
    assert_not_equal invite1.token, invite2.token
  end

  test "should be valid by default" do
    invite = @trip.invites.create!(created_by: @user)

    assert invite.invite_valid?
    assert invite.active?
    assert_not invite.expired?
  end

  test "should be invalid when revoked" do
    invite = @trip.invites.create!(created_by: @user)
    invite.revoke!

    assert_not invite.invite_valid?
    assert_not invite.active?
  end

  test "should be invalid when expired" do
    invite = @trip.invites.create!(created_by: @user, expires_at: 1.hour.ago)

    assert_not invite.invite_valid?
    assert invite.expired?
  end

  test "should validate token presence and uniqueness" do
    # Try to create without a token - should get one automatically
    invite = Invite.new(trip: @trip, created_by: @user)
    assert invite.valid? # Should be valid because token is auto-generated
    assert_not_nil invite.token

    invite.save!

    # Try to create another with same token
    duplicate = Invite.new(trip: @trip, created_by: @user, token: invite.token)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:token], "has already been taken"
  end
end
