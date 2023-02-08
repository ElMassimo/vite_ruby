# frozen_string_literal: true

require 'capybara/cuprite'

Capybara.register_driver(:cuprite) do |app, _options|
  cuprite_timeout = ENV.fetch('CUPRITE_TIMEOUT', 30).to_i

  Capybara::Cuprite::Driver.new(
    app,
    js_errors: true,
    browser_options: {
      'disable-infobars' => nil,
      'no-sandbox' => nil,
      'disable-dev-shm-usage' => nil,
      'disable-site-isolation-trials' => nil,
    },
    timeout: cuprite_timeout,
    process_timeout: cuprite_timeout,
    inspector: !ENV['CI'],
    headless: %w[true 1 yes].include?(ENV['HEADLESS'] || ENV['CI']),
    slowmo: ENV['SLOWMO'] == 'true' ? 0.1 : ENV['SLOWMO'],
  )
end

Capybara.configure do |config|
  config.default_driver = :cuprite
  config.javascript_driver = :cuprite

  config.match = :smart
  config.exact = true
  config.ignore_hidden_elements = true
  config.default_max_wait_time = 3
  config.default_normalize_ws = true
end
