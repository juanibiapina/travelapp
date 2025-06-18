require "test_helper"

class TransportTest < ActiveSupport::TestCase
  def setup
    @trip = trips(:one)
    @origin_place = places(:one)
    @destination_place = places(:three)
    @transport = @trip.transports.build(
      name: "Test Transport",
      start_date: Date.current + 1.day,
      end_date: Date.current + 1.day,
      origin_place: @origin_place,
      destination_place: @destination_place
    )
  end

  test "should be valid with valid attributes" do
    assert @transport.valid?
  end

  test "should require name" do
    @transport.name = nil
    assert_not @transport.valid?
    assert_includes @transport.errors[:name], "can't be blank"
  end

  test "should require name to not be empty" do
    @transport.name = ""
    assert_not @transport.valid?
    assert_includes @transport.errors[:name], "can't be blank"
  end

  test "should require start_date" do
    @transport.start_date = nil
    assert_not @transport.valid?
    assert_includes @transport.errors[:start_date], "can't be blank"
  end

  test "should require end_date" do
    @transport.end_date = nil
    assert_not @transport.valid?
    assert_includes @transport.errors[:end_date], "can't be blank"
  end

  test "should allow end_date to be same as start_date" do
    @transport.end_date = @transport.start_date
    assert @transport.valid?
  end

  test "should not allow end_date before start_date" do
    @transport.start_date = Date.current
    @transport.end_date = Date.current - 1.day
    assert_not @transport.valid?
    assert_includes @transport.errors[:end_date], "must be after or equal to the start date"
  end

  test "should belong to trip" do
    assert_equal @trip, @transport.trip
  end

  test "should belong to origin place" do
    assert_equal @origin_place, @transport.origin_place
  end

  test "should belong to destination place" do
    assert_equal @destination_place, @transport.destination_place
  end

  test "should require origin_place" do
    @transport.origin_place = nil
    assert_not @transport.valid?
    assert_includes @transport.errors[:origin_place], "must exist"
  end

  test "should require destination_place" do
    @transport.destination_place = nil
    assert_not @transport.valid?
    assert_includes @transport.errors[:destination_place], "must exist"
  end

  test "should validate start_date is within trip date range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    # Test start_date before trip start
    @transport.start_date = Date.current - 1.day
    @transport.end_date = Date.current + 1.day
    assert_not @transport.valid?
    assert_includes @transport.errors[:start_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test start_date after trip end
    @transport.start_date = Date.current + 8.days
    @transport.end_date = Date.current + 9.days
    assert_not @transport.valid?
    assert_includes @transport.errors[:start_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"
  end

  test "should validate end_date is within trip date range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    # Test end_date before trip start
    @transport.start_date = Date.current - 2.days
    @transport.end_date = Date.current - 1.day
    assert_not @transport.valid?
    assert_includes @transport.errors[:end_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test end_date after trip end
    @transport.start_date = Date.current + 1.day
    @transport.end_date = Date.current + 8.days
    assert_not @transport.valid?
    assert_includes @transport.errors[:end_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"
  end

  test "should be valid when dates are within trip range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    @transport.start_date = Date.current + 1.day
    @transport.end_date = Date.current + 3.days
    assert @transport.valid?
  end

  test "should validate origin_place belongs to same trip" do
    other_trip = trips(:two)
    other_place = places(:two) # This belongs to trip two
    @transport.origin_place = other_place
    assert_not @transport.valid?
    assert_includes @transport.errors[:origin_place], "must belong to the same trip"
  end

  test "should validate destination_place belongs to same trip" do
    other_trip = trips(:two)
    other_place = places(:two) # This belongs to trip two
    @transport.destination_place = other_place
    assert_not @transport.valid?
    assert_includes @transport.errors[:destination_place], "must belong to the same trip"
  end

  test "should have many users through transport_users" do
    @transport.save!
    user1 = users(:one)
    user2 = users(:two)

    @transport.users << user1
    @transport.users << user2

    assert_includes @transport.users, user1
    assert_includes @transport.users, user2
    assert_equal 2, @transport.users.count
  end

  test "should be destroyed when trip is destroyed" do
    # Create a fresh trip to avoid fixture complications
    fresh_trip = Trip.create!(
      name: "Fresh Trip",
      start_date: Date.current,
      end_date: Date.current + 7.days
    )

    # Create places for this trip
    origin = fresh_trip.places.create!(
      name: "Origin",
      start_date: Date.current + 1.day,
      end_date: Date.current + 3.days
    )
    destination = fresh_trip.places.create!(
      name: "Destination",
      start_date: Date.current + 2.days,
      end_date: Date.current + 4.days
    )

    # Create a transport for this trip
    transport = fresh_trip.transports.create!(
      name: "Fresh Transport",
      start_date: Date.current + 1.day,
      end_date: Date.current + 1.day,
      origin_place: origin,
      destination_place: destination
    )

    # Test that the transport belongs to the trip
    assert_equal fresh_trip, transport.trip

    # Count before deletion
    initial_transport_count = Transport.count

    # Destroy should work
    fresh_trip.destroy

    # The transport should be destroyed
    assert_equal initial_transport_count - 1, Transport.count
  end

  test "should not cause errors when trip exists" do
    # Test that our validation doesn't break existing functionality
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    transport = @trip.transports.build(
      name: "Test Transport",
      start_date: Date.current + 1.day,
      end_date: Date.current + 2.days,
      origin_place: @origin_place,
      destination_place: @destination_place
    )

    # Should be valid when dates are within range
    assert transport.valid?
  end
end
