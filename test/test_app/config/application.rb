# frozen_string_literal: true

require 'action_controller/railtie'
require 'action_view/railtie'

class Rails::Console; end

require 'spring/configuration'
Spring.application_root = File.expand_path('..', __dir__)

require 'vite_rails'

module TestApp
  class Application < ::Rails::Application
    config.secret_key_base = 'abcdef'
    config.eager_load = true
    config.active_support.test_order = :sorted
  end
end
