# frozen_string_literal: true

require 'test_helper'
require 'open3'

class BuilderTest < ViteRuby::Test
  delegate :builder, to: 'ViteRuby.instance'

  def last_build
    builder.last_build_metadata
  end

  def setup
    super
    builder.send(:last_build_path).tap do |path|
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
    assert last_build.stale?
    refute last_build.fresh?
  end

  def test_freshness_on_build_success
    assert last_build.stale?
    stub_runner(success: true) {
      assert builder.build
      assert last_build.success
      assert last_build.fresh?
      assert last_build.digest
      assert last_build.timestamp
    }
  end

  def test_freshness_on_build_fail
    assert last_build.stale?
    stub_runner(success: false) {
      refute builder.build
      refute last_build.success
      assert last_build.fresh?
      assert last_build.digest
      assert last_build.timestamp
    }
  end

  def test_last_build_path
    assert_equal builder.send(:last_build_path).basename.to_s, "last-build-#{ ViteRuby.config.mode }.json"
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

  def test_missing_executable
    refresh_config(vite_bin_path: 'none/vite')

    # It fails because we stub the File.exist? check, so the binary is missing.
    error = assert_raises(ViteRuby::MissingExecutableError) {
      File.stub(:exist?, true) { builder.build }
    }
    assert_match 'The vite binary is not available.', error.message

    # The provided binary does not exist, so it uses the default strategy.
    stub_runner(success: true) { assert builder.build }
  end

private

  def stub_runner(success:, &block)
    args = [:sterr, :stdout, OpenStruct.new(success?: success)]
    ViteRuby::IO.stub(:capture, args, &block)
  end
end
