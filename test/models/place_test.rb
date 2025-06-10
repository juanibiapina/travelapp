require "test_helper"

class PlaceTest < ActiveSupport::TestCase
  def setup
    @trip = trips(:one)
    @place = @trip.places.build(name: "Eiffel Tower")
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

  test "should belong to trip" do
    assert_equal @trip, @place.trip
  end
end
