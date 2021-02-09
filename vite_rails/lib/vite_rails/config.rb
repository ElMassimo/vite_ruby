# frozen_string_literal: true

module ViteRails::Config
  # Override: Default values for a Rails application.
  def config_defaults
    require 'rails'
    super(
      asset_host: Rails.application&.config&.action_controller&.asset_host,
      mode: Rails.env.to_s,
      root: Rails.root || Dir.pwd,
    )
  end
end

ViteRuby::Config.singleton_class.prepend(ViteRails::Config)
