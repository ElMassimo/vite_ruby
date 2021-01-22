# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < ViteRails::Test
  def expand_path(path)
    File.expand_path(Pathname.new(__dir__).join(path).to_s)
  end

  def assert_path(expected, actual)
    assert_equal expand_path(expected), actual.to_s
  end

  def assert_pathname(expected, actual)
    assert_equal Pathname.new(expand_path("test_app/#{ expected }")), actual
  end

  def resolve_config(mode: 'production', root: test_app_path, **attrs)
    ViteRails::Config.resolve_config(mode: mode, root: root, **attrs)
  end

  def setup
    @config = resolve_config
  end

  def test_source_code_dir
    assert_path 'test_app/app/frontend', @config.source_code_dir
  end

  def test_entrypoints_dir
    assert_path 'test_app/app/frontend/entrypoints', @config.resolved_entrypoints_dir
  end

  def test_public_dir
    assert_path 'test_app/public', @config.public_dir
  end

  def test_build_output_dir
    assert_path 'test_app/public/vite-production', @config.build_output_dir

    @config = resolve_config(config_path: 'config/vite_public_dir.json')
    assert_path 'public/vite', @config.build_output_dir
  end

  def test_manifest_path
    assert_path 'test_app/public/vite-production/manifest.json', @config.manifest_path
  end

  def test_build_cache_dir
    assert_path 'test_app/tmp/cache/vite', @config.build_cache_dir
  end

  def test_watch_additional_paths
    assert_equal [], @config.watch_additional_paths
    @config = resolve_config(config_path: 'config/vite_additional_paths.json')
    assert_equal ['config/*'], @config.watch_additional_paths
  end

  def test_auto_build
    refute @config.auto_build

    with_rails_env('development') do |config|
      assert config.auto_build
    end

    with_rails_env('test') do |config|
      assert config.auto_build
    end

    with_rails_env('staging') do |config|
      refute config.auto_build
    end
  end

  def test_protocol
    assert_equal 'http', @config.protocol
  end

  def test_host_with_port
    assert_equal 3036, @config.port

    with_rails_env('development') do |config|
      assert_equal 3535, config.port
      assert_equal 'localhost:3535', config.host_with_port
    end
  end

  def test_environment_vars
    ViteRails.env = {
      'VITE_RUBY_AUTO_BUILD' => 'true',
      'VITE_RUBY_HOST' => 'example.com',
      'VITE_RUBY_PORT' => '1920',
      'VITE_RUBY_HTTPS' => 'true',
      'VITE_RUBY_CONFIG_PATH' => 'config/vite_additional_paths.json',
      'VITE_RUBY_BUILD_CACHE_DIR' => 'tmp/vitebuild',
      'VITE_RUBY_PUBLIC_DIR' => 'pb',
      'VITE_RUBY_PUBLIC_OUTPUT_DIR' => 'ft',
      'VITE_RUBY_ASSETS_DIR' => 'as',
      'VITE_RUBY_SOURCE_CODE_DIR' => 'app',
      'VITE_RUBY_ENTRYPOINTS_DIR' => 'frontend/entrypoints',
      'VITE_RUBY_HIDE_BUILD_CONSOLE_OUTPUT' => 'true',
    }
    @config = resolve_config
    assert_equal true, @config.auto_build
    assert_equal 'example.com', @config.host
    assert_equal 1920, @config.port
    assert_equal true, @config.https
    assert_equal 'https', @config.protocol
    assert_equal Pathname.new('config/vite_additional_paths.json'), @config.config_path
    assert_pathname 'tmp/vitebuild', @config.build_cache_dir
    assert_pathname 'pb', @config.public_dir
    assert_equal Pathname.new('ft'), @config.public_output_dir
    assert_pathname 'pb/ft', @config.build_output_dir
    assert_equal 'as', @config.assets_dir
    assert_pathname 'app', @config.source_code_dir
    assert_equal 'frontend/entrypoints', @config.entrypoints_dir
    assert_pathname 'app/frontend/entrypoints', @config.resolved_entrypoints_dir
    assert_equal true, @config.hide_build_console_output
  ensure
    ViteRails.env = {}
  end
end
