# frozen_string_literal: true

require 'logger'
require 'forwardable'
require 'pathname'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{ __dir__ }/install")
loader.ignore("#{ __dir__ }/tasks")
loader.ignore("#{ __dir__ }/exe")
loader.inflector.inflect('cli' => 'CLI')
loader.setup

class ViteRuby
  # Internal: Prefix used for environment variables that modify the configuration.
  ENV_PREFIX = 'VITE_RUBY'

  # Internal: Versions used by default when running `vite install`.
  DEFAULT_VITE_VERSION = '^2.0.3'
  DEFAULT_PLUGIN_VERSION = '^1.0.13'

  # Internal: Ruby Frameworks that have a companion library for Vite Ruby.
  SUPPORTED_FRAMEWORKS = %w[rails hanami roda padrino sinatra].freeze

  class << self
    extend Forwardable

    def_delegators :instance, :config, :commands, :run_proxy?
    def_delegators :config, :mode

    def instance
      @instance ||= ViteRuby.new
    end

    # Public: Additional environment variables to pass to Vite.
    #
    # Example:
    #   ViteRuby.env['VITE_RUBY_CONFIG_PATH'] = 'config/alternate_vite.json'
    def env
      @env ||= load_env_variables
    end

    # Internal: Refreshes the manifest.
    def bootstrap
      instance.manifest.refresh
    end

    # Internal: Loads all available rake tasks.
    def install_tasks
      load File.expand_path('tasks/vite.rake', __dir__)
    end

    # Internal: Executes the vite binary.
    def run(argv, **options)
      ViteRuby::Runner.new(instance).run(argv, **options)
    end

    # Internal: Refreshes the config after setting the env vars.
    def reload_with(env_vars)
      env.update(env_vars)
      @instance = nil
      config
    end

    # Internal: Allows to obtain any env variables for configuration options.
    def load_env_variables
      ENV.select { |key, _| key.start_with?(ENV_PREFIX) }
    end

    # Internal: Detects if the application has installed a framework-specific
    # variant of Vite Ruby.
    def framework_libraries
      SUPPORTED_FRAMEWORKS.map { |framework|
        if library = Gem.loaded_specs["vite_#{ framework }"]
          [framework, library]
        end
      }.compact
    end
  end

  attr_writer :logger

  def logger
    @logger ||= Logger.new($stdout)
  end

  # Public: Returns true if the Vite development server is currently running.
  # NOTE: Checks only once every second since every lookup calls this method.
  def dev_server_running?
    return false unless run_proxy?
    return true if defined?(@running_at) && @running_at && Time.now - @running_at < 1

    Socket.tcp(config.host, config.port, connect_timeout: config.dev_server_connect_timeout).close
    @running_at = Time.now
    true
  rescue
    @running_at = false
  end

  # Public: The proxy for assets should only run in development mode.
  def run_proxy?
    config.mode == 'development'
  rescue StandardError => error
    logger.error("Failed to check mode for Vite: #{ error.message }")
    false
  end

  # Public: Keeps track of watched files and triggers builds as needed.
  def builder
    @builder ||= ViteRuby::Builder.new(self)
  end

  # Internal: Helper to run commands related with Vite.
  def commands
    @commands ||= ViteRuby::Commands.new(self)
  end

  # Public: Current instance configuration for Vite.
  def config
    @config ||= ViteRuby::Config.resolve_config
  end

  # Public: Enables looking up assets managed by Vite using name and type.
  def manifest
    @manifest ||= ViteRuby::Manifest.new(self)
  end
end
