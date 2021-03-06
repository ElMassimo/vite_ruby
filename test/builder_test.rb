# frozen_string_literal: true

require 'test_helper'
require 'open3'

class BuilderTest < ViteRuby::Test
  delegate :builder, to: 'ViteRuby.instance'

  def setup
    super
    builder.send(:files_digest_path).tap do |path|
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
    assert_equal vite_env['FOO'], 'BAR'
  end

  def test_freshness
    assert builder.stale?
    refute builder.fresh?
  end

  def test_freshness_on_build_success
    assert builder.stale?
    stub_runner(success: true) {
      assert builder.build
      assert builder.fresh?
      assert builder.last_build['digest']
      assert builder.last_build['success']
    }
  end

  def test_freshness_on_build_fail
    assert builder.stale?
    stub_runner(success: false) {
      refute builder.build
      assert builder.fresh?
      assert builder.last_build['digest']
      refute builder.last_build['success']
    }
  end

  def test_files_digest_path
    assert_equal builder.send(:files_digest_path).basename.to_s, "last-compilation-#{ ViteRuby.config.mode }"
  end

  def test_watched_files_digest
    previous_digest = builder.send(:watched_files_digest)
    refresh_config
    assert_equal previous_digest, builder.send(:watched_files_digest)
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
    refresh_config
  end

private

  def stub_runner(success:, &block)
    args = [:sterr, :stdout, OpenStruct.new(success?: success)]
    ViteRuby::Runner.stub_any_instance(:capture3_with_output, args, &block)
  end
end
