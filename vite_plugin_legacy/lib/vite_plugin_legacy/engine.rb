# frozen_string_literal: true

require "rails/railtie"

class VitePluginLegacy::Engine < Rails::Engine
  initializer "vite_plugin_legacy.helper" do
    ActiveSupport.on_load(:action_controller) do
      ActionController::Base.helper(VitePluginLegacy::TagHelpers)
    end

    ActiveSupport.on_load(:action_view) do
      include VitePluginLegacy::TagHelpers
    end
  end
end
