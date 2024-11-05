# frozen_string_literal: true

require "rails/railtie"

class ViteRailsLegacy::Engine < Rails::Engine
  initializer "vite_rails.proxy" do |app|
    app.middleware.insert_before 0, "ViteRuby::DevServerProxy", ssl_verify_none: true if ViteRuby.run_proxy?
  end

  initializer "vite_rails_legacy.helper" do
    ActiveSupport.on_load(:action_controller) do
      ActionController::Base.helper(ViteRailsLegacy::TagHelpers)
    end

    ActiveSupport.on_load(:action_view) do
      include ViteRailsLegacy::TagHelpers
    end
  end

  initializer "vite_rails.logger" do
    config.after_initialize do
      ViteRuby.instance.logger = Rails.logger
    end
  end

  initializer "vite_rails.bootstrap" do
    if defined?(Rails::Server) || defined?(Rails::Console)
      ViteRuby.bootstrap
      if defined?(Spring)
        require "spring/watcher"
        Spring.after_fork { ViteRuby.bootstrap }
        Spring.watch(ViteRuby.config.config_path)
      end
    end
  end
end
