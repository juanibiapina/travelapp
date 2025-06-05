require "test_helper"

class LinkTest < ActiveSupport::TestCase
  def setup
    @trip = trips(:one)
    @link = @trip.links.build(url: "https://example.com")
  end

  test "should be valid with valid attributes" do
    assert @link.valid?
  end

  test "should require url" do
    @link.url = nil
    assert_not @link.valid?
    assert_includes @link.errors[:url], "can't be blank"
  end

  test "should require valid url format" do
    @link.url = "not-a-url"
    assert_not @link.valid?
    assert_includes @link.errors[:url], "must be a valid URL"
  end

  test "should accept valid http url" do
    @link.url = "http://example.com"
    assert @link.valid?
  end

  test "should accept valid https url" do
    @link.url = "https://example.com"
    assert @link.valid?
  end

  test "should belong to trip" do
    assert_equal @trip, @link.trip
  end
end
