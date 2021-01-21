# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < ViteRails::Test
  def expanded_path(path)
    File.expand_path(Pathname.new(__dir__).join(path).to_s)
  end

  def setup
    @config = ViteRails::Config.resolve_config(
      mode: 'production',
      root: expanded_path('test_app'),
      config_path: 'test_app/config/vite.json',
    )
  end

  def test_source_dir
    assert_equal expanded_path('test_app/app/frontend'), @config.source_code_dir.to_s
  end

  def test_source_entry_path
    source_entry_path = expanded_path('test_app/app/javascript', 'packs')
    assert_equal @config.source_entry_path.to_s, source_entry_path
  end

  def test_public_root_path
    public_root_path = expanded_path('test_app/public')
    assert_equal @config.public_path.to_s, public_root_path
  end

  def test_public_output_path
    public_output_path = expanded_path('test_app/public/packs')
    assert_equal @config.public_output_path.to_s, public_output_path

    @config = ViteRails::Configuration.new(
      root_path: @config.root_path,
      config_path: Pathname.new(File.expand_expanded_path('./test_app/config/vite_public_root.yml', __dir__)),
      env: 'production',
    )

    public_output_path = expanded_path('public/packs')
    assert_equal @config.public_output_path.to_s, public_output_path
  end

  def test_public_manifest_path
    public_manifest_path = expanded_path('test_app/public/packs', 'manifest.json')
    assert_equal @config.public_manifest_path.to_s, public_manifest_path
  end

  def test_cache_path
    cache_path = expanded_path('test_app/tmp/cache/vite')
    assert_equal @config.cache_path.to_s, cache_path
  end

  def test_additional_paths
    assert_equal @config.additional_paths, ['app/assets', '/etc/yarn', 'some.config.js', 'app/elm']
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
