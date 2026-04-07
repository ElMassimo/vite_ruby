# frozen_string_literal: true

require "test_helper"

describe "Builder" do
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

  def stub_runner(errors: "", success: errors.empty?, &block)
    args = ["stdout", errors, MockProcessStatus.new(success: success)]
    ViteRuby::IO.stub(:capture, args, &block)
  end

  test "custom environment variables" do
    expect(vite_env["FOO"]) == nil
    ViteRuby.env["FOO"] = "BAR"

    expect(vite_env["FOO"]) == "BAR"
    expect(vite_env("FOO" => "OTHER")["FOO"]) == "OTHER"
  end

  test "freshness" do
    expect(last_build).to_be(:stale?)
    expect(last_build).not_to_be(:fresh?)
  end

  test "freshness on build success" do
    expect(last_build).to_be(:stale?)
    stub_runner(success: true) {
      assert(builder.build)
      assert(last_build.success)
      expect(last_build.errors).to_be(:empty?)
      expect(last_build).to_be(:fresh?)
      assert(last_build.digest)
      assert(last_build.timestamp)

      refresh_config(auto_build: true)

      expect(manifest.send(:lookup, "app.css")) != nil
    }
  end

  test "freshness on build fail" do
    expect(last_build).to_be(:stale?)
    error_message = "SyntaxError: Hero.jsx: Unexpected token (6:6)"
    stub_runner(errors: error_message) {
      refute(builder.build)
      refute(last_build.success)
      expect(last_build.errors) == error_message
      expect(last_build).to_be(:fresh?)
      assert(last_build.digest)
      assert(last_build.timestamp)

      refresh_config(auto_build: true)

      expect(manifest.send(:lookup, "app.css")) == nil
    }
  end

  test "last build path" do
    expect(builder.send(:last_build_path, ssr: false).basename.to_s) == "last-build-#{ViteRuby.config.mode}.json"
    expect(builder.send(:last_build_path, ssr: true).basename.to_s) == "last-ssr-build-#{ViteRuby.config.mode}.json"
  end

  test "watched files digest" do
    previous_digest = ViteRuby.digest
    refresh_config

    expect(ViteRuby.digest) == previous_digest
  end

  test "external env variables" do
    expect(vite_env["VITE_RUBY_MODE"]) == "production"
    expect(vite_env["VITE_RUBY_ROOT"]) == Rails.root.to_s

    ENV["VITE_RUBY_MODE"] = "foo.bar"
    ENV["VITE_RUBY_ROOT"] = "/baz"
    refresh_config

    expect(vite_env["VITE_RUBY_MODE"]) == "foo.bar"
    expect(vite_env["VITE_RUBY_ROOT"]) == "/baz"
  ensure
    ENV.delete("VITE_RUBY_MODE")
    ENV.delete("VITE_RUBY_ROOT")
    refresh_config
  end

  test "missing executable" do
    refresh_config(vite_bin_path: "none/vite")

    # It fails because we stub File.exist? so the binary appears missing.
    expect {
      File.stub(:exist?, true) { builder.build }
    }.to_raise(ViteRuby::MissingExecutableError) do |error|
      expect(error.message).to_include("The vite binary is not available.")
    end

    # The provided binary does not exist, so it uses the default strategy.
    stub_runner(success: true) { assert(builder.build) }
  end

  test "build cache" do
    build = ViteRuby::Build.from_previous(Pathname.new(__FILE__), "digest")

    expect(build.timestamp) == "never"
    expect(build).to_be(:retry_failed?)
  end
end
