require "test_helper"

class TripTest < ActiveSupport::TestCase
  test "should have start and end dates" do
    trip = Trip.new(name: "Test Trip")
    assert_not trip.valid?
    assert_includes trip.errors[:start_date], "can't be blank"
    assert_includes trip.errors[:end_date], "can't be blank"
  end

  test "should be valid with all required attributes" do
    trip = Trip.new(
      name: "Test Trip",
      start_date: Date.current,
      end_date: Date.current + 7.days
    )
    assert trip.valid?
  end

  test "end date must be after start date" do
    trip = Trip.new(
      name: "Test Trip",
      start_date: Date.current,
      end_date: Date.current - 1.day
    )
    assert_not trip.valid?
    assert_includes trip.errors[:end_date], "must be after the start date"
  end

  test "end date can be same as start date" do
    trip = Trip.new(
      name: "Test Trip",
      start_date: Date.current,
      end_date: Date.current
    )
    assert trip.valid?
  end

  test "should include validation error in fixtures for testing" do
    # Test that our validation works by creating an invalid trip
    trip = Trip.new(
      name: "Invalid Trip",
      start_date: Date.current + 5.days,
      end_date: Date.current
    )
    assert_not trip.valid?
    assert_includes trip.errors[:end_date], "must be after the start date"
  end
end
