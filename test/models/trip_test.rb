require "test_helper"

class TripTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @trip = @user.trips.build(
      name: "Test Trip",
      start_date: Date.current + 1.day,
      end_date: Date.current + 7.days
    )
  end

  test "should be valid with valid attributes" do
    assert @trip.valid?
  end

  test "should require start date" do
    @trip.start_date = nil
    assert_not @trip.valid?
    assert_includes @trip.errors[:start_date], "can't be blank"
  end

  test "should require end date" do
    @trip.end_date = nil
    assert_not @trip.valid?
    assert_includes @trip.errors[:end_date], "can't be blank"
  end

  test "end date should be after start date" do
    @trip.start_date = Date.current + 7.days
    @trip.end_date = Date.current + 1.day
    assert_not @trip.valid?
    assert_includes @trip.errors[:end_date], "must be after start date"
  end

  test "end date should not equal start date" do
    same_date = Date.current + 1.day
    @trip.start_date = same_date
    @trip.end_date = same_date
    assert_not @trip.valid?
    assert_includes @trip.errors[:end_date], "must be after start date"
  end
end
