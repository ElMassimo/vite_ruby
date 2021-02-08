# frozen_string_literal: true

require 'test_helper'

class BuilderTest < ViteRuby::Test
  def setup
    refresh_config
    ViteRuby.builder.send(:files_digest_path).tap do |path|
      path.delete if path.exist?
    end
  end

  def teardown
    setup
  end

  def vite_env
    ViteRuby.config.to_env
  end

  def test_custom_environment_variables
    assert_nil vite_env['FOO']
    ViteRuby.env['FOO'] = 'BAR'
    assert vite_env['FOO'] == 'BAR'
  end

  def test_freshness
    assert ViteRuby.builder.stale?
    assert !ViteRuby.builder.fresh?
  end

  def test_build
    assert !ViteRuby.builder.build
  end

  def test_freshness_on_build_success
    assert ViteRuby.builder.stale?
    status = OpenStruct.new(success?: true)
    Open3.stub :capture3, [:sterr, :stdout, status] do
      assert ViteRuby.builder.build
      assert ViteRuby.builder.fresh?
    end
  end

  def test_freshness_on_build_fail
    assert ViteRuby.builder.stale?
    status = OpenStruct.new(success?: false)
    Open3.stub :capture3, [:sterr, :stdout, status] do
      assert !ViteRuby.builder.build
      assert ViteRuby.builder.fresh?
    end
  end

  def test_files_digest_path
    assert_equal ViteRuby.builder.send(:files_digest_path).basename.to_s, "last-compilation-digest-#{ ViteRuby.config.mode }"
  end

  def test_watched_files_digest
    previous_digest = ViteRuby.builder.send(:watched_files_digest)
    refresh_config
    assert_equal previous_digest, ViteRuby.builder.send(:watched_files_digest)
  end

  def test_external_env_variables
    assert_equal 'production', vite_env['VITE_RUBY_MODE']
    assert_equal Rails.root.to_s, vite_env['VITE_RUBY_ROOT']

    ENV['VITE_RUBY_MODE'] = 'foo.bar'
    ENV['VITE_RUBY_ROOT'] = '/baz'
    refresh_config
    assert_equal 'foo.bar', vite_env['VITE_RUBY_MODE']
    assert_equal '/baz', vite_env['VITE_RUBY_ROOT']
  ensure
    ENV.delete('VITE_RUBY_MODE')
    ENV.delete('VITE_RUBY_ROOT')
  end
end
