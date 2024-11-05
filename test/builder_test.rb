# frozen_string_literal: true

require "test_helper"
require "open3"

class BuilderTest < ViteRuby::Test
  delegate :builder, :manifest, to: "ViteRuby.instance"

  def last_build
    builder.last_build_metadata
  end

  def setup
    super
    [builder.send(:last_build_path, ssr: true), builder.send(:last_build_path, ssr: false)].each do |path|
      path.delete if path.exist?
    end
  end

  def teardown
    setup
  end

  def vite_env(*vars)
    ViteRuby.config.to_env(*vars)
  end

  def test_custom_environment_variables
    assert_nil vite_env["FOO"]
    ViteRuby.env["FOO"] = "BAR"

    assert_equal "BAR", vite_env["FOO"]
    assert_equal "OTHER", vite_env("FOO" => "OTHER")["FOO"]
  end

  def test_freshness
    assert_predicate last_build, :stale?
    refute_predicate last_build, :fresh?
  end

  def test_freshness_on_build_success
    assert_predicate last_build, :stale?
    stub_runner(success: true) {
      assert builder.build
      assert last_build.success
      assert_empty last_build.errors
      assert_predicate last_build, :fresh?
      assert last_build.digest
      assert last_build.timestamp

      refresh_config(auto_build: true)

      refute_nil manifest.send(:lookup, "app.css")
    }
  end

  def test_freshness_on_build_fail
    assert_predicate last_build, :stale?
    error_message = "SyntaxError: Hero.jsx: Unexpected token (6:6)"
    stub_runner(errors: error_message) {
      refute builder.build
      refute last_build.success
      assert_equal last_build.errors, error_message
      assert_predicate last_build, :fresh?
      assert last_build.digest
      assert last_build.timestamp

      refresh_config(auto_build: true)

      assert_nil manifest.send(:lookup, "app.css")
    }
  end

  def test_last_build_path
    assert_equal builder.send(:last_build_path, ssr: false).basename.to_s, "last-build-#{ViteRuby.config.mode}.json"
    assert_equal builder.send(:last_build_path, ssr: true).basename.to_s, "last-ssr-build-#{ViteRuby.config.mode}.json"
  end

  def test_watched_files_digest
    previous_digest = ViteRuby.digest
    refresh_config

    assert_equal previous_digest, ViteRuby.digest
  end

  def test_external_env_variables
    assert_equal "production", vite_env["VITE_RUBY_MODE"]
    assert_equal Rails.root.to_s, vite_env["VITE_RUBY_ROOT"]

    ENV["VITE_RUBY_MODE"] = "foo.bar"
    ENV["VITE_RUBY_ROOT"] = "/baz"
    refresh_config

    assert_equal "foo.bar", vite_env["VITE_RUBY_MODE"]
    assert_equal "/baz", vite_env["VITE_RUBY_ROOT"]
  ensure
    ENV.delete("VITE_RUBY_MODE")
    ENV.delete("VITE_RUBY_ROOT")
    refresh_config
  end

  def test_missing_executable
    refresh_config(vite_bin_path: "none/vite")

    # It fails because we stub the File.exist? check, so the binary is missing.
    error = assert_raises(ViteRuby::MissingExecutableError) {
      File.stub(:exist?, true) { builder.build }
    }

    assert_match "The vite binary is not available.", error.message

    # The provided binary does not exist, so it uses the default strategy.
    stub_runner(success: true) { assert builder.build }
  end

  def test_build_cache
    build = ViteRuby::Build.from_previous(Pathname.new(__FILE__), "digest")

    assert_equal("never", build.timestamp)
    assert_predicate(build, :retry_failed?)
  end

private

  def stub_runner(errors: "", success: errors.empty?, &block)
    args = ["stdout", errors, MockProcessStatus.new(success: success)]
    ViteRuby::IO.stub(:capture, args, &block)
  end
end
