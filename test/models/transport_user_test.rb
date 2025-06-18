require "test_helper"

class TransportUserTest < ActiveSupport::TestCase
  def setup
    @transport = transports(:one)
    @user = users(:three) # Use a different user to avoid fixture conflicts
    @transport_user = TransportUser.new(transport: @transport, user: @user)
  end

  test "should be valid with valid attributes" do
    assert @transport_user.valid?
  end

  test "should belong to transport" do
    assert_equal @transport, @transport_user.transport
  end

  test "should belong to user" do
    assert_equal @user, @transport_user.user
  end

  test "should require transport" do
    @transport_user.transport = nil
    assert_not @transport_user.valid?
    assert_includes @transport_user.errors[:transport], "must exist"
  end

  test "should require user" do
    @transport_user.user = nil
    assert_not @transport_user.valid?
    assert_includes @transport_user.errors[:user], "must exist"
  end

  test "should not allow duplicate transport-user combinations" do
    @transport_user.save!
    duplicate = TransportUser.new(transport: @transport, user: @user)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:transport_id], "has already been taken"
  end

  test "should allow same user with different transports" do
    @transport_user.save!
    other_transport = transports(:two)
    other_transport_user = TransportUser.new(transport: other_transport, user: @user)
    assert other_transport_user.valid?
  end

  test "should allow same transport with different users" do
    # Create a fresh transport to avoid fixture conflicts
    trip = trips(:one)
    origin = places(:one)
    destination = places(:three)

    fresh_transport = Transport.create!(
      name: "Fresh Transport",
      start_date: Date.current + 1.day,
      end_date: Date.current + 1.day,
      trip: trip,
      origin_place: origin,
      destination_place: destination
    )

    # Create first association
    first_transport_user = TransportUser.create!(transport: fresh_transport, user: users(:one))

    # Create second association with different user - this should work
    second_transport_user = TransportUser.new(transport: fresh_transport, user: users(:two))
    assert second_transport_user.valid?
  end
end
