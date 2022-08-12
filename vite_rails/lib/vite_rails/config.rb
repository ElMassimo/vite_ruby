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
    require 'rails'

    if ENV['NODE_ENV'] == 'production' && !Rails.application&.initialized?
      require File.expand_path('config/environment', Dir.pwd)
    end
  rescue StandardError, LoadError
  end
end

ViteRuby::Config.singleton_class.prepend(ViteRails::Config)
