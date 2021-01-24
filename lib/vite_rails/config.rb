# frozen_string_literal: true

require 'json'

# Public: Allows to resolve configuration sourced from `config/vite.json` and
# environment variables, combining them with the default options.
class ViteRails::Config
  delegate :as_json, :inspect, to: :@config

  def initialize(attrs)
    @config = attrs.tap { |config| coerce_values(config) }.freeze
  end

  def protocol
    https ? 'https' : 'http'
  end

  def host_with_port
    "#{ host }:#{ port }"
  end

  # Internal: Path where Vite outputs the manifest file.
  def manifest_path
    build_output_dir.join('manifest.json')
  end

  # Public: The directory where Vite will store the built assets.
  def build_output_dir
    root.join(public_dir, public_output_dir)
  end

  # Public: The directory where the entries are located.
  def resolved_entrypoints_dir
    root.join(source_code_dir, entrypoints_dir)
  end

  # Internal: The directory where Vite stores its processing cache.
  def vite_cache_dir
    root.join('node_modules/.vite')
  end

  # Public: Sets additional environment variables for vite-plugin-ruby.
  def to_env
    CONFIGURABLE_WITH_ENV.each_with_object({}) do |option, env|
      unless (value = @config[option]).nil?
        env["#{ ViteRails::ENV_PREFIX }_#{ option.upcase }"] = value.to_s
      end
    end.merge(ViteRails.env)
  end

private

  # Internal: Coerces all the configuration values, in case they were passed
  # as environment variables which are always strings.
  def coerce_values(config)
    config['mode'] = config['mode'].to_s
    config['port'] = config['port'].to_i
    config['root'] = Pathname.new(config['root'])
    config['build_cache_dir'] = config['root'].join(config['build_cache_dir'])
    coerce_booleans(config, 'auto_build', 'hide_build_console_output', 'https')
  end

  # Internal: Coerces configuration options to boolean.
  def coerce_booleans(config, *names)
    names.each { |name| config[name] = [true, 'true'].include?(config[name]) }
  end

  class << self
    # Public: Returns the project configuration for Vite.
    def resolve_config(attrs = {})
      config = attrs.transform_keys(&:to_s).reverse_merge(config_defaults)
      file_path = File.join(config['root'], config['config_path'])
      file_config = config_from_file(file_path, mode: config['mode'])
      new DEFAULT_CONFIG.merge(file_config).merge(config_from_env).merge(config)
    end

  private

    # Internal: Default values for a Rails application.
    def config_defaults
      {
        'asset_host' => option_from_env('asset_host') || Rails.application&.config&.action_controller&.asset_host,
        'config_path' => option_from_env('config_path') || DEFAULT_CONFIG.fetch('config_path'),
        'mode' => option_from_env('mode') || Rails.env.to_s,
        'root' => option_from_env('root') || Rails.root || Dir.pwd,
      }
    end

    # Internal: Used to load a JSON file from the specified path.
    def load_json(path)
      JSON.parse(File.read(File.expand_path(path))).deep_transform_keys(&:underscore)
    end

    # Internal: Retrieves a configuration option from environment variables.
    def option_from_env(name)
      ViteRails.env["#{ ViteRails::ENV_PREFIX }_#{ name.upcase }"]
    end

    # Internal: Extracts the configuration options provided as env vars.
    def config_from_env
      CONFIGURABLE_WITH_ENV.each_with_object({}) do |option, env_vars|
        if value = option_from_env(option)
          env_vars[option] = value
        end
      end
    end

    # Internal: Loads the configuration options provided in a JSON file.
    def config_from_file(path, mode:)
      multi_env_config = load_json(path)
      multi_env_config.fetch('all', {})
        .merge(multi_env_config.fetch(mode, {}))
    rescue Errno::ENOENT => error
      warn "Check that your vite.json configuration file is available in the load path. #{ error.message }"
      {}
    end
  end

  # Internal: Shared configuration with the Vite plugin for Ruby.
  DEFAULT_CONFIG = load_json("#{ __dir__ }/../../package/default.vite.json").freeze

  # Internal: Configuration options that can not be provided as env vars.
  NOT_CONFIGURABLE_WITH_ENV = %w[watch_additional_paths].freeze

  # Internal: Configuration options that can be provided as env vars.
  CONFIGURABLE_WITH_ENV = (DEFAULT_CONFIG.keys + %w[mode root] - NOT_CONFIGURABLE_WITH_ENV).freeze

public

  # Define getters for the configuration options.
  (CONFIGURABLE_WITH_ENV + NOT_CONFIGURABLE_WITH_ENV).each do |option|
    define_method(option) { @config[option] }
  end
end
