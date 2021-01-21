# frozen_string_literal: true



# Public: Allows to resolve configuration sourced from `config/vite.json` and
# environment variables, combining them with the default options.
class ViteRails::Config
  delegate :as_json, :inspect, to: :@config

  def initialize(attrs)
    @config = attrs.transform_keys(&:to_s).tap { |config| coerce_values(config) }.freeze

    # Define getters for the configuration options.
    @config.each_key do |option|
      define_singleton_method(option) { @config[option] }
    end
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
    public_dir.join(public_output_dir)
  end

private

  # Internal: Coerces all the configuration values, in case they were passed
  # as environment variables which are always strings.
  def coerce_values(config)
    config['root'] ||= Rails.root
    config['port'] = config['port'].to_i
    coerce_booleans(config, 'auto_build', 'https')
    coerce_paths(config, 'assets_dir', 'build_cache_dir', 'config_path', 'public_dir', 'source_code_dir', 'public_output_dir', 'root')

    # Prefix paths that are relative to the project root.
    config.slice('build_cache_dir', 'public_dir', 'source_code_dir').each do |option, dir|
      config[option] = config['root'].join(dir) if dir
    end
  end

  # Internal: Coerces configuration options to boolean.
  def coerce_booleans(config, *names)
    names.each { |name| config[name] = [true, 'true'].include?(config[name]) }
  end

  # Internal: Converts configuration options to pathname.
  def coerce_paths(config, *names)
    names.each { |name| config[name] = Pathname.new(config[name]) unless config[name].nil? }
  end

  class << self
    # Public: Returns the project configuration for Vite.
    def resolve_config(attrs = {})
      new DEFAULT_CONFIG.merge(config_from_file).merge(config_from_env).merge(attrs)
    rescue Errno::ENOENT => error
      warn "Check that your vite.json configuration file is available in the load path. #{ error.message }"
      new DEFAULT_CONFIG.merge(config_from_env)
    end

  private

    # Internal: Used to load a JSON file from the specified path.
    def load_json(path)
      JSON.parse(File.read(File.expand_path(path))).deep_transform_keys(&:underscore)
    end

    # Internal: Retrieves a configuration option from environment variables.
    def config_option_from_env(name)
      ENV["#{ ViteRails::ENV_PREFIX }_#{ name.upcase }"]
    end

    # Internal: Extracts the configuration options provided as env vars.
    def config_from_env
      CONFIGURABLE_WITH_ENV.each_with_object({}) do |key, env_vars|
        if value = config_option_from_env(key)
          env_vars[key] = value
        end
      end.merge(mode: vite_mode)
    end

    # Internal: The mode Vite should run on.
    def vite_mode
      config_option_from_env('mode') || Rails.env.to_s
    end

    # Internal: Loads the configuration options provided in a JSON file.
    def config_from_file
      path = config_option_from_env('config_path') || DEFAULT_CONFIG.fetch('config_path')
      multi_env_config = load_json(path)
      multi_env_config.fetch('all', {})
        .merge(multi_env_config.fetch(vite_mode, {}))
    end
  end

  # Internal: Shared configuration with the Vite plugin for Ruby.
  DEFAULT_CONFIG = load_json("#{ __dir__ }/../../package/default.vite.json").freeze

  # Internal: Configuration options that can be provided as env vars.
  CONFIGURABLE_WITH_ENV = (DEFAULT_CONFIG.keys + ['root']).freeze
end
