require "test_helper"

class PlaceTest < ActiveSupport::TestCase
  def setup
    @trip = trips(:one)
    @place = @trip.places.build(
      name: "Eiffel Tower",
      start_date: Date.current + 1.day,
      end_date: Date.current + 3.days
    )
  end

  test "should be valid with valid attributes" do
    assert @place.valid?
  end

  test "should require name" do
    @place.name = nil
    assert_not @place.valid?
    assert_includes @place.errors[:name], "can't be blank"
  end

  test "should require name to not be empty" do
    @place.name = ""
    assert_not @place.valid?
    assert_includes @place.errors[:name], "can't be blank"
  end

  test "should require start_date" do
    @place.start_date = nil
    assert_not @place.valid?
    assert_includes @place.errors[:start_date], "can't be blank"
  end

  test "should require end_date" do
    @place.end_date = nil
    assert_not @place.valid?
    assert_includes @place.errors[:end_date], "can't be blank"
  end

  test "should allow end_date to be same as start_date" do
    @place.end_date = @place.start_date
    assert @place.valid?
  end

  test "should not allow end_date before start_date" do
    @place.start_date = Date.current + 3.days
    @place.end_date = Date.current + 1.day
    assert_not @place.valid?
    assert_includes @place.errors[:end_date], "must be after or equal to the start date"
  end

  test "should belong to trip" do
    assert_equal @trip, @place.trip
  end

  test "should validate start_date is within trip date range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    # Test start_date before trip start
    @place.start_date = Date.current - 1.day
    @place.end_date = Date.current + 1.day
    assert_not @place.valid?
    assert_includes @place.errors[:start_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test start_date after trip end
    @place.start_date = Date.current + 8.days
    @place.end_date = Date.current + 9.days
    assert_not @place.valid?
    assert_includes @place.errors[:start_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"
  end

  test "should validate end_date is within trip date range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    # Test end_date before trip start
    @place.start_date = Date.current - 2.days
    @place.end_date = Date.current - 1.day
    assert_not @place.valid?
    assert_includes @place.errors[:end_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test end_date after trip end
    @place.start_date = Date.current + 1.day
    @place.end_date = Date.current + 8.days
    assert_not @place.valid?
    assert_includes @place.errors[:end_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"
  end

  test "should allow place dates within trip date range" do
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    # Test dates exactly on trip boundaries
    @place.start_date = Date.current
    @place.end_date = Date.current + 7.days
    assert @place.valid?

    # Test dates within trip range
    @place.start_date = Date.current + 1.day
    @place.end_date = Date.current + 3.days
    assert @place.valid?
  end

  test "should not cause errors when trip exists" do
    # Test that our validation doesn't break existing functionality
    @trip.update!(start_date: Date.current, end_date: Date.current + 7.days)

    place = @trip.places.build(
      name: "Test Place",
      start_date: Date.current + 1.day,
      end_date: Date.current + 2.days
    )

    # Should be valid when dates are within range
    assert place.valid?
  end
end
