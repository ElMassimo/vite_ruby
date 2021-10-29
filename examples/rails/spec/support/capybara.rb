# frozen_string_literal: true

require 'selenium/webdriver'

def create_chrome_driver(app)
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--disable-infobars')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  yield(options) if block_given?

  Capybara::Selenium::Driver.new(app, browser: :chrome, native_displayed: true, options: options)
end

Capybara.register_driver :chrome do |app|
  create_chrome_driver(app)
end

Capybara.register_driver :chrome_headless do |app|
  create_chrome_driver(app) do |options|
    options.add_argument('--headless')
  end
end

[:chrome, :chrome_headless].each do |name|
  Capybara::Screenshot.register_driver(name) { |driver, path|
    driver.browser.save_screenshot(path)
  }
end

# Overriden configuration for new tests.
Capybara.configure do |config|
  # It's the most commonly used driver.
  config.default_driver = ENV['HEADLESS'] ? :chrome_headless : :chrome
  config.javascript_driver = :chrome

  # The recommended approach in Capybara.
  config.match = :smart
  config.exact = true
  config.ignore_hidden_elements = true
  config.default_max_wait_time = 3
end
