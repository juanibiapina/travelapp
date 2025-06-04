require "test_helper"

class RoutingTest < ActionDispatch::IntegrationTest
  test "root route points to trips index" do
    get "/"
    assert_response :success
    assert_select "h1", "Trips"
  end

  test "root route shows the same content as trips index" do
    get "/"
    root_body = response.body
    
    get trips_path
    trips_index_body = response.body
    
    assert_equal trips_index_body, root_body
  end
end