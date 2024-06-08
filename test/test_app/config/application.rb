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
    config.load_defaults Rails::VERSION::STRING.to_f
    config.secret_key_base = SecureRandom.hex
    config.eager_load = true
    config.active_support.test_order = :sorted

    if Rails.gem_version >= Gem::Version.new('7.0.0')
      # Option added in Rails 7.0, defaults to false. Some helper_test tests assume true.
      config.action_view.apply_stylesheet_media_default = true
    end
  end
end
