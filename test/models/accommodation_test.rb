require "test_helper"

class AccommodationTest < ActiveSupport::TestCase
  def setup
    @place = places(:one)
    @trip = trips(:one)
    @accommodation = @place.accommodations.build(
      title: "Test Hotel",
      start_date: Date.current + 1.day,
      end_date: Date.current + 3.days
    )
  end

  test "should be valid with valid attributes" do
    assert @accommodation.valid?
  end

  test "should require title" do
    @accommodation.title = nil
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:title], "can't be blank"
  end

  test "should require start_date" do
    @accommodation.start_date = nil
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:start_date], "can't be blank"
  end

  test "should require end_date" do
    @accommodation.end_date = nil
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:end_date], "can't be blank"
  end

  test "should allow end_date to be same as start_date" do
    @accommodation.end_date = @accommodation.start_date
    assert @accommodation.valid?
  end

  test "should not allow end_date before start_date" do
    @accommodation.start_date = Date.current + 3.days
    @accommodation.end_date = Date.current + 1.day
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:end_date], "must be after or equal to the start date"
  end

  test "should belong to place" do
    assert_equal @place, @accommodation.place
  end

  test "should access trip through place" do
    assert_equal @trip, @accommodation.trip
  end

  test "should validate start_date is within trip date range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    # Test start_date before trip start
    @accommodation.start_date = Date.current - 1.day
    @accommodation.end_date = Date.current + 1.day
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:start_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test start_date after trip end
    @accommodation.start_date = Date.current + 8.days
    @accommodation.end_date = Date.current + 9.days
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:start_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"
  end

  test "should validate end_date is within trip date range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    # Test end_date before trip start
    @accommodation.start_date = Date.current - 2.days
    @accommodation.end_date = Date.current - 1.day
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:end_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test end_date after trip end
    @accommodation.start_date = Date.current + 1.day
    @accommodation.end_date = Date.current + 8.days
    assert_not @accommodation.valid?
    assert_includes @accommodation.errors[:end_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"
  end

  test "should be valid when dates are within trip range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    @accommodation.start_date = Date.current + 1.day
    @accommodation.end_date = Date.current + 3.days
    assert @accommodation.valid?
  end

  test "should not cause errors when trip exists" do
    # Test that our validation doesn't break existing functionality
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    accommodation = @place.accommodations.build(
      title: "Test Accommodation",
      start_date: Date.current + 1.day,
      end_date: Date.current + 2.days
    )

    # Should be valid when dates are within range
    assert accommodation.valid?
  end
end
