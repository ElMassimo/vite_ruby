# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < ViteRails::Test
  def expand_path(path)
    File.expand_path(Pathname.new(__dir__).join(path).to_s)
  end

  def assert_path(expected, actual)
    assert_equal expand_path(expected), actual.to_s
  end

  def resolve_config(mode: 'production', root: expand_path('test_app'), **attrs)
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

  def test_public_root_path
    assert_path 'test_app/public', @config.public_dir
  end

  def test_public_output_path
    assert_path 'test_app/public/vite-production', @config.build_output_dir

    @config = resolve_config(config_path: 'config/vite_public_dir.json')
    assert_path 'public/vite', @config.build_output_dir
  end

  def test_public_manifest_path
    public_manifest_path = expand_path('test_app/public/packs', 'manifest.json')
    assert_path @config.public_manifest_path.to_s, public_manifest_path
  end

  def test_cache_path
    cache_path = expand_path('test_app/tmp/cache/vite')
    assert_path @config.cache_path.to_s, cache_path
  end

  def test_additional_paths
    assert_path @config.additional_paths, ['app/assets', '/etc/yarn', 'some.config.js', 'app/elm']
  end

  def test_cache_manifest?
    assert @config.cache_manifest?

    with_rails_env('development') do
      refute ViteRails.config.cache_manifest?
    end

    with_rails_env('test') do
      refute ViteRails.config.cache_manifest?
    end
  end

  def test_compile?
    refute @config.compile?

    with_rails_env('development') do
      assert ViteRails.config.compile?
    end

    with_rails_env('test') do
      assert ViteRails.config.compile?
    end
  end
end
