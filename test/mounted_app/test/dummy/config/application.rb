# frozen_string_literal: true

require 'action_controller/railtie'
require 'action_view/railtie'

if RUBY_VERSION.start_with?('2.4')
  require 'vite_rails_legacy'
  ViteRails = ViteRailsLegacy
else
  require 'vite_rails'
end

module TestDummyApp
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.secret_key_base = SecureRandom.hex
    config.eager_load = true
  end
end
