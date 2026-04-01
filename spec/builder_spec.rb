# frozen_string_literal: true

require "spec_helper"
require "open3"

RSpec.describe "ViteRuby::Builder" do
  delegate :builder, :manifest, to: "ViteRuby.instance"

  def last_build
    builder.last_build_metadata
  end

  def vite_env(*vars)
    ViteRuby.config.to_env(*vars)
  end

  before do
    [builder.send(:last_build_path, ssr: true), builder.send(:last_build_path, ssr: false)].each do |path|
      path.delete if path.exist?
    end
  end

  after do
    [builder.send(:last_build_path, ssr: true), builder.send(:last_build_path, ssr: false)].each do |path|
      path.delete if path.exist?
    end
  end

  it "custom_environment_variables" do
    expect(vite_env["FOO"]).to be_nil
    ViteRuby.env["FOO"] = "BAR"

    expect(vite_env["FOO"]).to eq("BAR")
    expect(vite_env("FOO" => "OTHER")["FOO"]).to eq("OTHER")
  ensure
    ViteRuby.env.delete("FOO")
  end

  it "freshness" do
    expect(last_build).to be_stale
    expect(last_build).not_to be_fresh
  end

  it "freshness_on_build_success" do
    expect(last_build).to be_stale
    stub_runner(success: true) {
      expect(builder.build).to be_truthy
      expect(last_build.success).to be_truthy
      expect(last_build.errors).to be_empty
      expect(last_build).to be_fresh
      expect(last_build.digest).to be_truthy
      expect(last_build.timestamp).to be_truthy

      refresh_config(auto_build: true)

      expect(manifest.send(:lookup, "app.css")).not_to be_nil
    }
  end

  it "freshness_on_build_fail" do
    expect(last_build).to be_stale
    error_message = "SyntaxError: Hero.jsx: Unexpected token (6:6)"
    stub_runner(errors: error_message) {
      expect(builder.build).to be_falsy
      expect(last_build.success).to be_falsy
      expect(last_build.errors).to eq(error_message)
      expect(last_build).to be_fresh
      expect(last_build.digest).to be_truthy
      expect(last_build.timestamp).to be_truthy

      refresh_config(auto_build: true)

      expect(manifest.send(:lookup, "app.css")).to be_nil
    }
  end

  it "last_build_path" do
    expect(builder.send(:last_build_path, ssr: false).basename.to_s).to eq("last-build-#{ViteRuby.config.mode}.json")
    expect(builder.send(:last_build_path, ssr: true).basename.to_s).to eq("last-ssr-build-#{ViteRuby.config.mode}.json")
  end

  it "watched_files_digest" do
    previous_digest = ViteRuby.digest
    refresh_config

    expect(ViteRuby.digest).to eq(previous_digest)
  end

  it "external_env_variables" do
    expect(vite_env["VITE_RUBY_MODE"]).to eq("production")
    expect(vite_env["VITE_RUBY_ROOT"]).to eq(Rails.root.to_s)

    ENV["VITE_RUBY_MODE"] = "foo.bar"
    ENV["VITE_RUBY_ROOT"] = "/baz"
    refresh_config

    expect(vite_env["VITE_RUBY_MODE"]).to eq("foo.bar")
    expect(vite_env["VITE_RUBY_ROOT"]).to eq("/baz")
  ensure
    ENV.delete("VITE_RUBY_MODE")
    ENV.delete("VITE_RUBY_ROOT")
    refresh_config
  end

  it "missing_executable" do
    refresh_config(vite_bin_path: "none/vite")

    error = nil
    File.stub(:exist?, true) {
      expect {
        begin
          builder.build
        rescue ViteRuby::MissingExecutableError => e
          error = e
        end
      }.not_to raise_error
    }
    expect(error).to be_a(ViteRuby::MissingExecutableError)
    expect(error.message).to include("The vite binary is not available.")

    stub_runner(success: true) { expect(builder.build).to be_truthy }
  end

  it "build_cache" do
    build = ViteRuby::Build.from_previous(Pathname.new(__FILE__), "digest")

    expect(build.timestamp).to eq("never")
    expect(build).to be_retry_failed
  end

private

  def stub_runner(errors: "", success: errors.empty?)
    args = ["stdout", errors, MockProcessStatus.new(success: success)]
    allow(ViteRuby::IO).to receive(:capture).and_return(args)
    yield
  end
end
