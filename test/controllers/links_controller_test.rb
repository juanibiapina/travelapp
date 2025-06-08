require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @trip = trips(:one)
    @link = links(:one)
    sign_in @account
  end

  test "should get index" do
    get trip_links_url(@trip)
    assert_response :success
  end

  test "should get new" do
    get new_trip_link_url(@trip)
    assert_response :success
  end

  test "should create link" do
    assert_difference("Link.count") do
      post trip_links_url(@trip), params: { link: { url: "https://example.com" } }
    end

    assert_redirected_to trip_url(@trip)
  end

  test "should not create link with invalid url" do
    assert_no_difference("Link.count") do
      post trip_links_url(@trip), params: { link: { url: "not-a-url" } }
    end

    assert_redirected_to trip_url(@trip)
    follow_redirect!
    assert_select ".bg-red-100", text: /must be a valid URL/
  end

  test "should show link" do
    get trip_link_url(@trip, @link)
    assert_response :success
  end

  test "should get edit" do
    get edit_trip_link_url(@trip, @link)
    assert_response :success
  end

  test "should update link" do
    patch trip_link_url(@trip, @link), params: { link: { url: "https://updated.com" } }
    assert_redirected_to trip_link_url(@trip, @link)
  end

  test "should destroy link" do
    assert_difference("Link.count", -1) do
      delete trip_link_url(@trip, @link)
    end

    assert_redirected_to trip_url(@trip)
  end
end
