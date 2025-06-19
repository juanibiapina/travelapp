require "test_helper"

class DateRangeValidatableTest < ActiveSupport::TestCase
  # Test using a simple class that includes the concern
  class TestModel
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include DateRangeValidatable

    attribute :start_date, :date
    attribute :end_date, :date
    attribute :trip

    # Mock trip object for testing
    Trip = Struct.new(:start_date, :end_date)
  end

  def setup
    @model = TestModel.new
    @trip = TestModel::Trip.new(Date.current, Date.current + 7.days)
    @model.trip = @trip
  end

  test "should validate end_date is after or equal to start_date" do
    @model.start_date = Date.current + 2.days
    @model.end_date = Date.current + 1.day
    assert_not @model.valid?
    assert_includes @model.errors[:end_date], "must be after or equal to the start date"

    # Should be valid when end_date equals start_date
    @model.end_date = @model.start_date
    @model.errors.clear
    @model.valid?
    assert_not @model.errors.key?(:end_date)

    # Should be valid when end_date is after start_date
    @model.end_date = @model.start_date + 1.day
    @model.errors.clear
    @model.valid?
    assert_not @model.errors.key?(:end_date)
  end

  test "should validate dates are within trip range" do
    # Test start_date before trip start
    @model.start_date = @trip.start_date - 1.day
    @model.end_date = @trip.start_date + 1.day
    assert_not @model.valid?
    assert_includes @model.errors[:start_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test start_date after trip end
    @model.start_date = @trip.end_date + 1.day
    @model.end_date = @trip.end_date + 2.days
    @model.errors.clear
    assert_not @model.valid?
    assert_includes @model.errors[:start_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"

    # Test end_date before trip start
    @model.start_date = @trip.start_date - 2.days
    @model.end_date = @trip.start_date - 1.day
    @model.errors.clear
    assert_not @model.valid?
    assert_includes @model.errors[:end_date], "must be on or after the trip start date (#{@trip.start_date.strftime('%B %d, %Y')})"

    # Test end_date after trip end
    @model.start_date = @trip.end_date - 1.day
    @model.end_date = @trip.end_date + 1.day
    @model.errors.clear
    assert_not @model.valid?
    assert_includes @model.errors[:end_date], "must be on or before the trip end date (#{@trip.end_date.strftime('%B %d, %Y')})"

    # Should be valid when dates are within trip range
    @model.start_date = @trip.start_date + 1.day
    @model.end_date = @trip.end_date - 1.day
    @model.errors.clear
    @model.valid?
    assert_not @model.errors.key?(:start_date)
    assert_not @model.errors.key?(:end_date)
  end

  test "should skip validation when dates are nil" do
    @model.start_date = nil
    @model.end_date = nil
    @model.valid?
    assert_not @model.errors.key?(:start_date)
    assert_not @model.errors.key?(:end_date)
  end

  test "should skip trip range validation when trip has no dates" do
    @model.trip = TestModel::Trip.new(nil, nil)
    @model.start_date = Date.current - 1.day
    @model.end_date = Date.current + 1.day
    @model.valid?
    assert_not @model.errors.key?(:start_date)
    assert_not @model.errors.key?(:end_date)
  end
end
