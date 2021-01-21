# frozen_string_literal: true

require 'test_helper'

class BuilderTest < ViteRails::Test
  def setup
    refresh_config
    ViteRails.clobber
  end

  def teardown
    ViteRails.clobber
  end

  def vite_env
    ViteRails.builder.send(:vite_env)
  end

  def test_custom_environment_variables
    assert_nil vite_env['FOO']
    ViteRails.env['FOO'] = 'BAR'
    assert vite_env['FOO'] == 'BAR'
  end

  def test_freshness
    assert ViteRails.builder.stale?
    assert !ViteRails.builder.fresh?
  end

  def test_build
    assert !ViteRails.builder.build
  end

  def test_freshness_on_build_success
    assert ViteRails.builder.stale?
    status = OpenStruct.new(success?: true)
    Open3.stub :capture3, [:sterr, :stdout, status] do
      assert ViteRails.builder.build
      assert ViteRails.builder.fresh?
    end
  end

  def test_freshness_on_build_fail
    status = OpenStruct.new(success?: false)

    assert ViteRails.builder.stale?
    Open3.stub :capture3, [:sterr, :stdout, status] do
      ViteRails.builder.build
      assert ViteRails.builder.fresh?
    end
  end

  def test_files_digest_path
    assert_equal ViteRails.builder.send(:files_digest_path).basename.to_s, "last-compilation-digest-#{ ViteRails.config.mode }"
  end

  def test_external_env_variables
    ViteRails.env = {}
    assert_equal vite_env['VITE_RUBY_MODE'], 'production'
    assert_equal vite_env['VITE_RUBY_ROOT'], Rails.root.to_s

    ENV['VITE_RUBY_MODE'] = 'foo.bar'
    ENV['VITE_RUBY_ROOT'] = '/baz'

    assert_equal vite_env['VITE_RUBY_MODE'], 'foo.bar'
    assert_equal vite_env['VITE_RUBY_ROOT'], '/baz'
  end
end
