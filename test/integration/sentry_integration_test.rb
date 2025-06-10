require "test_helper"

class SentryIntegrationTest < ActionDispatch::IntegrationTest
  test "Sentry is properly configured in test environment" do
    # Sentry should not be enabled in test environment
    assert_not Sentry.configuration.enabled_environments.include?("test"),
               "Sentry should not be enabled in test environment"
  end

  test "Sentry configuration has correct environment settings" do
    config = Sentry.configuration

    # Check that production and staging are enabled environments
    assert_includes config.enabled_environments, "production"
    assert_includes config.enabled_environments, "staging"

    # Check that environment is set correctly
    assert_equal Rails.env, config.environment
  end

  test "Sentry DSN is configurable via environment variable" do
    # Test with a mock DSN
    original_dsn = ENV["SENTRY_DSN"]
    test_dsn = "https://test@example.ingest.sentry.io/test"

    begin
      ENV["SENTRY_DSN"] = test_dsn
      # Reinitialize Sentry configuration
      load Rails.root.join("config/initializers/sentry.rb")

      assert_equal test_dsn, Sentry.configuration.dsn.to_s
    ensure
      ENV["SENTRY_DSN"] = original_dsn
      # Restore original configuration
      load Rails.root.join("config/initializers/sentry.rb")
    end
  end
end
