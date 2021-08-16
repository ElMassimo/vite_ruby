# frozen_string_literal: true

require 'action_controller/railtie'
require 'action_view/railtie'

class Rails::Console; end

if RUBY_VERSION.start_with?('2.4')
  require 'vite_rails_legacy'
  ViteRails = ViteRailsLegacy
else
  require 'spring/configuration'
  Spring.application_root = File.expand_path('..', __dir__)
  require 'vite_rails'
end

require 'vite_plugin_legacy'

module TestApp
  class Application < ::Rails::Application
    config.secret_key_base = 'abcdef'
    config.eager_load = true
    config.active_support.test_order = :sorted
  end
end
