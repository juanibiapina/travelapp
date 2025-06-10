require "test_helper"

class TripEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @trip = trips(:one)
    @trip_event = trip_events(:one)
    sign_in @account
  end

  test "should get index" do
    get trip_trip_events_url(@trip)
    assert_response :success
  end

  test "should get new" do
    get new_trip_trip_event_url(@trip)
    assert_response :success
  end

  test "should create trip_event" do
    assert_difference("TripEvent.count") do
      post trip_trip_events_url(@trip), params: {
        trip_event: {
          title: "New Event",
          start_date: Date.current,
          end_date: Date.current + 1.day
        }
      }
    end

    assert_redirected_to trip_trip_events_url(@trip)
  end

  test "should not create trip_event with invalid attributes" do
    assert_no_difference("TripEvent.count") do
      post trip_trip_events_url(@trip), params: {
        trip_event: {
          title: "",
          start_date: Date.current,
          end_date: Date.current - 1.day
        }
      }
    end

    assert_redirected_to trip_trip_events_url(@trip)
  end

  test "should show trip_event" do
    get trip_trip_event_url(@trip, @trip_event)
    assert_response :success
  end

  test "should get edit" do
    get edit_trip_trip_event_url(@trip, @trip_event)
    assert_response :success
  end

  test "should update trip_event" do
    patch trip_trip_event_url(@trip, @trip_event), params: {
      trip_event: {
        title: "Updated Event",
        start_date: @trip_event.start_date,
        end_date: @trip_event.end_date
      }
    }
    assert_redirected_to trip_trip_event_url(@trip, @trip_event)
  end

  test "should destroy trip_event" do
    assert_difference("TripEvent.count", -1) do
      delete trip_trip_event_url(@trip, @trip_event)
    end

    assert_redirected_to trip_trip_events_url(@trip)
  end

  test "should require authentication" do
    sign_out @account

    get trip_trip_events_url(@trip)
    assert_redirected_to new_account_session_path
  end
end
