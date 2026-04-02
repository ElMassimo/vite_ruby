# frozen_string_literal: true

require "test_helper"
require "open3"

describe "BuilderTest" do
  include ViteRubyTestHelpers

  def builder
    ViteRuby.instance.builder
  end

  def manifest
    ViteRuby.instance.manifest
  end

  def last_build
    builder.last_build_metadata
  end

  before do
    [builder.send(:last_build_path, ssr: true), builder.send(:last_build_path, ssr: false)].each do |path|
      path.delete if path.exist?
    end
  end

  after do |_error|
    [builder.send(:last_build_path, ssr: true), builder.send(:last_build_path, ssr: false)].each do |path|
      path.delete if path.exist?
    end
  end

  def vite_env(*vars)
    ViteRuby.config.to_env(*vars)
  end

  it "custom_environment_variables" do
    expect(vite_env["FOO"]).to be_nil
    ViteRuby.env["FOO"] = "BAR"

    expect(vite_env["FOO"]).to be == "BAR"
    expect(vite_env("FOO" => "OTHER")["FOO"]).to be == "OTHER"
  end

  it "freshness" do
    expect(last_build).to be(:stale?)
    expect(last_build).not.to be(:fresh?)
  end

  it "freshness_on_build_success" do
    expect(last_build).to be(:stale?)
    stub_runner(success: true) {
      expect(builder.build).to be_truthy
      expect(last_build.success).to be_truthy
      expect(last_build.errors).to be(:empty?)
      expect(last_build).to be(:fresh?)
      expect(last_build.digest).not.to be_nil
      expect(last_build.timestamp).not.to be_nil

      refresh_config(auto_build: true)

      expect(manifest.send(:lookup, "app.css")).not.to be_nil
    }
  end

  it "freshness_on_build_fail" do
    expect(last_build).to be(:stale?)
    error_message = "SyntaxError: Hero.jsx: Unexpected token (6:6)"
    stub_runner(errors: error_message) {
      expect(builder.build).to be_falsey
      expect(last_build.success).to be_falsey
      expect(last_build.errors).to be == error_message
      expect(last_build).to be(:fresh?)
      expect(last_build.digest).not.to be_nil
      expect(last_build.timestamp).not.to be_nil

      refresh_config(auto_build: true)

      expect(manifest.send(:lookup, "app.css")).to be_nil
    }
  end

  it "last_build_path" do
    expect(builder.send(:last_build_path, ssr: false).basename.to_s).to be == "last-build-#{ViteRuby.config.mode}.json"
    expect(builder.send(:last_build_path, ssr: true).basename.to_s).to be == "last-ssr-build-#{ViteRuby.config.mode}.json"
  end

  it "watched_files_digest" do
    previous_digest = ViteRuby.digest
    refresh_config

    expect(ViteRuby.digest).to be == previous_digest
  end

  it "external_env_variables" do
    expect(vite_env["VITE_RUBY_MODE"]).to be == "production"
    expect(vite_env["VITE_RUBY_ROOT"]).to be == Rails.root.to_s

    ENV["VITE_RUBY_MODE"] = "foo.bar"
    ENV["VITE_RUBY_ROOT"] = "/baz"
    refresh_config

    expect(vite_env["VITE_RUBY_MODE"]).to be == "foo.bar"
    expect(vite_env["VITE_RUBY_ROOT"]).to be == "/baz"
  ensure
    ENV.delete("VITE_RUBY_MODE")
    ENV.delete("VITE_RUBY_ROOT")
    refresh_config
  end

  it "missing_executable" do
    refresh_config(vite_bin_path: "none/vite")

    # It fails because we stub the File.exist? check, so the binary is missing.
    error = nil
    expect {
      File.stub(:exist?, true) { builder.build }
    }.to raise_exception(ViteRuby::MissingExecutableError)

    File.stub(:exist?, true) {
      begin
        builder.build
      rescue ViteRuby::MissingExecutableError => e
        error = e
      end
    }

    expect(error.message).to be.include?("The vite binary is not available.")

    # The provided binary does not exist, so it uses the default strategy.
    stub_runner(success: true) { expect(builder.build).to be_truthy }
  end

  it "build_cache" do
    build = ViteRuby::Build.from_previous(Pathname.new(__FILE__), "digest")

    expect(build.timestamp).to be == "never"
    expect(build).to be(:retry_failed?)
  end

private

  def stub_runner(errors: "", success: errors.empty?, &block)
    args_result = ["stdout", errors, MockProcessStatus.new(success: success)]
    mock(ViteRuby::IO).replace(:capture) { args_result }
    yield
  end
end
