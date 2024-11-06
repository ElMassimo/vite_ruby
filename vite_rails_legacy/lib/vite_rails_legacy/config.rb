# frozen_string_literal: true

module ViteRailsLegacy::Config
  # Override: Default values for a Rails application.
  def config_defaults
    require "rails"
    asset_host = Rails.application&.config&.action_controller&.asset_host
    super(
      asset_host: asset_host.is_a?(Proc) ? nil : asset_host,
      mode: Rails.env.to_s,
      root: Rails.root || Dir.pwd,
    )
  end
end

require "active_support/core_ext/hash"
ViteRuby::Config.singleton_class.prepend(ViteRailsLegacy::Config)
