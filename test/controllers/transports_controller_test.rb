require "test_helper"

class TransportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @trip = trips(:one)
    @transport = transports(:one)
    sign_in @account
  end

  test "should get index" do
    get trip_transports_url(@trip)
    assert_response :success
  end

  test "should get new" do
    get new_trip_transport_url(@trip)
    assert_response :success
  end

  test "should create transport" do
    assert_difference("Transport.count") do
      post trip_transports_url(@trip), params: {
        transport: {
          name: "Flight AA123",
          start_date: Date.current,
          end_date: Date.current,
          origin_place_id: places(:one).id,    # places(:one) belongs to trips(:one)
          destination_place_id: places(:three).id, # places(:three) belongs to trips(:one)
          user_ids: [ @user.id ]
        }
      }
    end

    assert_redirected_to trip_transports_url(@trip)
  end

  test "should not create transport with invalid data" do
    assert_no_difference("Transport.count") do
      post trip_transports_url(@trip), params: {
        transport: {
          name: "",
          start_date: "",
          end_date: "",
          origin_place_id: "",
          destination_place_id: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show transport" do
    get trip_transport_url(@trip, @transport)
    assert_response :success
  end

  test "should get edit" do
    get edit_trip_transport_url(@trip, @transport)
    assert_response :success
  end

  test "should update transport" do
    patch trip_transport_url(@trip, @transport), params: {
      transport: {
        name: "Updated Flight",
        start_date: @transport.start_date,
        end_date: @transport.end_date,
        origin_place_id: @transport.origin_place_id,
        destination_place_id: @transport.destination_place_id
      }
    }
    assert_redirected_to trip_transport_url(@trip, @transport)
  end

  test "should destroy transport" do
    assert_difference("Transport.count", -1) do
      delete trip_transport_url(@trip, @transport)
    end

    assert_redirected_to trip_transports_url(@trip)
  end

  test "should not allow access to transport from different trip" do
    other_trip = trips(:two)
    get trip_transport_url(other_trip, @transport)
    assert_response :not_found
  end
end
