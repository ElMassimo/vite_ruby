# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/class/attribute_accessors'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{ __dir__ }/install")
loader.ignore("#{ __dir__ }/tasks")
loader.setup

class ViteRails
  # Internal: Prefix used for environment variables that modify the configuration.
  ENV_PREFIX = 'VITE_RUBY'

  class << self
    delegate :config, :builder, :manifest, :commands, :dev_server, :dev_server_running?, to: :instance
    delegate :mode, to: :config
    delegate :bootstrap, :clean, :clobber, :build, to: :commands

    attr_writer :instance

    def instance
      @instance ||= ViteRails.new
    end

    def run(args)
      $stdout.sync = true
      ViteRails::Runner.new(args).run
    end

    # Public: The proxy for assets should only run in development mode.
    def run_proxy?
      config.mode == 'development'
    rescue StandardError => error
      logger.error("Failed to check mode for Vite: #{ error.message }")
      false
    end

    def with_node_env(env)
      original = ENV['NODE_ENV']
      ENV['NODE_ENV'] = env
      yield
    ensure
      ENV['NODE_ENV'] = original
    end

    # Internal: Allows to obtain any env variables for configuration options.
    def load_env_variables
      ENV.select { |key, _| key.start_with?(ENV_PREFIX) }
    end

    def ensure_log_goes_to_stdout
      old_logger = ViteRails.logger
      ViteRails.logger = ActiveSupport::Logger.new(STDOUT)
      yield
    ensure
      ViteRails.logger = old_logger
    end
  end

  # Public: Additional environment variables to pass to Vite.
  #
  # Example:
  #   ViteRails.env['VITE_RUBY_CONFIG_PATH'] = 'config/alternate_vite.json'
  cattr_accessor(:env) { load_env_variables }

  cattr_accessor(:logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) }

  # Public: Returns true if the Vite development server is running.
  def dev_server_running?
    ViteRails.run_proxy? && dev_server.running?
  end

  # Public: Current instance configuration for Vite.
  def config
    @config ||= ViteRails::Config.resolve_config
  end

  # Public: Keeps track of watched files and triggers builds as needed.
  def builder
    @builder ||= ViteRails::Builder.new(self)
  end

  # Public: Allows to check if the Vite development server is running.
  def dev_server
    @dev_server ||= ViteRails::DevServer.new(config)
  end

  # Public: Enables looking up assets managed by Vite using name and type.
  def manifest
    @manifest ||= ViteRails::Manifest.new(self)
  end

  # Internal: Helper to run commands related with Vite.
  def commands
    @commands ||= ViteRails::Commands.new(self)
  end
end

ViteRails::Engine if defined?(Rails)
