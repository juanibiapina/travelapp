require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Configure Chrome options for different environments
  chrome_options = {}
  chrome_options[:args] = [ "--no-sandbox", "--disable-dev-shm-usage" ]

  # Additional args for CI environments
  if ENV["CI"] || ENV["GITHUB_ACTIONS"] || Rails.env.test?
    chrome_options[:args] << "--disable-gpu"
    chrome_options[:args] << "--disable-web-security"
    chrome_options[:args] << "--disable-features=VizDisplayCompositor"
    chrome_options[:args] << "--disable-extensions"
  end

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_option|
    chrome_options[:args].each { |arg| driver_option.add_argument(arg) }
  end

  include Devise::Test::IntegrationHelpers
end
