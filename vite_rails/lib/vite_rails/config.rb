# frozen_string_literal: true

module ViteRails::Config
private

  # Override: Default values for a Rails application.
  def config_defaults
    ensure_rails_init
    asset_host = Rails.application&.config&.action_controller&.asset_host
    super(
      asset_host: asset_host.is_a?(Proc) ? nil : asset_host,
      mode: Rails.env.to_s,
      root: Rails.root || Dir.pwd,
    )
  end

  # Internal: Attempts to initialize the Rails application.
  def ensure_rails_init
    require File.expand_path('config/boot', Dir.pwd)
    require File.expand_path('config/application', Dir.pwd)
    unless Rails.application.initialized?
      Rails.application.require_environment!
    end
  rescue StandardError, LoadError
    require 'rails'
  end
end

ViteRuby::Config.singleton_class.prepend(ViteRails::Config)
