require "test_helper"

class HealthCheckTest < ActionDispatch::IntegrationTest
  test "health check endpoint returns success" do
    get "/up"
    assert_response :success
  end

  test "health check endpoint content type" do
    get "/up"
    assert_response :success
    # The rails/health controller typically returns plain text
    assert_match(/text/, response.content_type)
  end
end
