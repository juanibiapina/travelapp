require "test_helper"

class AccommodationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @trip = trips(:one)
    @place = places(:one)
    @accommodation = accommodations(:one)
    sign_in @account
  end

  test "should get index" do
    get trip_accommodations_url(@trip)
    assert_response :success
  end

  test "should get new" do
    get new_trip_accommodation_url(@trip)
    assert_response :success
  end

  test "should create accommodation" do
    assert_difference("Accommodation.count") do
      post trip_accommodations_url(@trip), params: {
        accommodation: {
          title: "New Hotel",
          start_date: Date.current + 1.day,
          end_date: Date.current + 3.days,
          place_id: @place.id
        }
      }
    end

    assert_redirected_to trip_accommodations_url(@trip)
  end

  test "should show accommodation" do
    get trip_accommodation_url(@trip, @accommodation)
    assert_response :success
  end

  test "should get edit" do
    get edit_trip_accommodation_url(@trip, @accommodation)
    assert_response :success
  end

  test "should update accommodation" do
    patch trip_accommodation_url(@trip, @accommodation), params: {
      accommodation: {
        title: "Updated Hotel"
      }
    }
    assert_redirected_to trip_accommodation_url(@trip, @accommodation)
  end

  test "should destroy accommodation" do
    assert_difference("Accommodation.count", -1) do
      delete trip_accommodation_url(@trip, @accommodation)
    end

    assert_redirected_to trip_accommodations_url(@trip)
  end

  test "should not create accommodation with invalid data" do
    assert_no_difference("Accommodation.count") do
      post trip_accommodations_url(@trip), params: {
        accommodation: {
          title: "",  # Invalid title
          start_date: Date.current + 1.day,
          end_date: Date.current + 3.days,
          place_id: @place.id
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
