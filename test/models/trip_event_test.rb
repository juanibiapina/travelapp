require "test_helper"

class TripEventTest < ActiveSupport::TestCase
  def setup
    @trip = trips(:one)
    @trip_event = @trip.trip_events.build(
      title: "Test Event",
      start_date: Date.current,
      end_date: Date.current + 1.day
    )
  end

  test "should be valid with valid attributes" do
    assert @trip_event.valid?
  end

  test "should require title" do
    @trip_event.title = nil
    assert_not @trip_event.valid?
    assert_includes @trip_event.errors[:title], "can't be blank"
  end

  test "should require start_date" do
    @trip_event.start_date = nil
    assert_not @trip_event.valid?
    assert_includes @trip_event.errors[:start_date], "can't be blank"
  end

  test "should require end_date" do
    @trip_event.end_date = nil
    assert_not @trip_event.valid?
    assert_includes @trip_event.errors[:end_date], "can't be blank"
  end

  test "should allow end_date to be same as start_date" do
    @trip_event.end_date = @trip_event.start_date
    assert @trip_event.valid?
  end

  test "should not allow end_date before start_date" do
    @trip_event.start_date = Date.current
    @trip_event.end_date = Date.current - 1.day
    assert_not @trip_event.valid?
    assert_includes @trip_event.errors[:end_date], "must be after or equal to the start date"
  end

  test "should belong to trip" do
    assert_equal @trip, @trip_event.trip
  end

  test "should be destroyed when trip is destroyed" do
    @trip_event.save!
    trip_events_count = @trip.trip_events.count
    assert_difference("TripEvent.count", -trip_events_count) do
      @trip.destroy
    end
  end
end
