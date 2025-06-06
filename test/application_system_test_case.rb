require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Configure Chrome options for different environments
  chrome_options = {}
  chrome_options[:args] = [
    # Core sandbox and memory flags
    "--no-sandbox",
    "--disable-dev-shm-usage",

    # Network and connectivity flags to avoid firewall issues
    "--disable-background-networking",
    "--disable-default-apps",
    "--disable-sync",
    "--disable-translate",
    "--disable-extensions",
    "--disable-component-update",
    "--disable-domain-reliability",
    "--disable-client-side-phishing-detection",

    # Chrome services and features
    "--disable-features=NetworkService,SafeBrowsingService,VizDisplayCompositor,TranslateUI",
    "--disable-backgrounding-occluded-windows",
    "--disable-renderer-backgrounding",
    "--disable-breakpad",
    "--disable-component-extensions-with-background-pages",

    # Performance and interaction flags
    "--disable-hang-monitor",
    "--disable-popup-blocking",
    "--disable-prompt-on-repost",
    "--disable-ipc-flooding-protection",
    "--disable-background-timer-throttling",
    "--disable-renderer-accessibility",

    # Browser behavior flags
    "--disable-web-resources",
    "--disable-zero-browsers-open-for-tests",
    "--no-default-browser-check",
    "--no-first-run",
    "--no-service-autorun",
    "--password-store=basic",
    "--use-mock-keychain",
    "--metrics-recording-only",
    "--safebrowsing-disable-auto-update",

    # Additional isolation flags
    "--disable-gpu",
    "--disable-web-security"
  ]

  # Additional args for CI environments (removed redundant flags)
  if ENV["CI"] || ENV["GITHUB_ACTIONS"] || Rails.env.test?
    # GPU and web security flags are already included above
  end

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_option|
    chrome_options[:args].each { |arg| driver_option.add_argument(arg) }
  end

  include Devise::Test::IntegrationHelpers
end
