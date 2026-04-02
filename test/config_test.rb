# frozen_string_literal: true

require "test_helper"

CONFIG_TEST_DIR = File.expand_path(__dir__)

describe "ConfigTest" do
  include ViteRubyTestHelpers

  let(:config) { resolve_config }

  def expand_path(path)
    File.expand_path(Pathname.new(CONFIG_TEST_DIR).join(path).to_s)
  end

  def assert_path(expected, actual)
    expect(actual.to_s).to be == expand_path(expected)
  end

  def assert_pathname(expected, actual)
    expect(actual).to be == Pathname.new(expand_path("test_app/#{expected}"))
  end

  def resolve_config(mode: "production", root: path_to_test_app, **attrs)
    ViteRuby::Config.resolve_config(mode: mode, root: root, **attrs)
  end

  it "matching_default_config_json" do
    root = Pathname.new(CONFIG_TEST_DIR).join("..")

    expect(root.join("vite-plugin-ruby/default.vite.json").read).to be == root.join("vite_ruby/default.vite.json").read
  end

  it "source_code_dir" do
    expect(config.source_code_dir).to be == "app/frontend"
  end

  it "entrypoints_dir" do
    assert_path "test_app/app/frontend/entrypoints", config.resolved_entrypoints_dir
  end

  it "vite_root_dir" do
    assert_path "test_app/app/frontend", config.vite_root_dir
  end

  it "public_dir" do
    expect(config.public_dir).to be == "public"
  end

  it "build_output_dir" do
    assert_path "test_app/public/vite-production", config.build_output_dir

    other_config = resolve_config(config_path: "config/vite_public_dir.json")

    assert_path "public/vite", other_config.build_output_dir
  end

  it "ruby_config_file" do
    expect(config.to_env["EXAMPLE_PATH"]).to be_nil

    refresh_config(config_path: "config/vite_public_dir.json")

    expect(ViteRuby.config.public_output_dir).to be == "from_ruby"
    expect(ViteRuby.config.to_env["EXAMPLE_PATH"]).to be == Gem.loaded_specs["rails"].full_gem_path
  end

  it "manifest_path" do
    assert_path "test_app/public/vite-production/.vite/manifest.json", config.manifest_paths.first
  end

  it "build_cache_dir" do
    assert_path "test_app/tmp/cache/vite", config.build_cache_dir
  end

  it "watch_additional_paths" do
    expect(config.watch_additional_paths).to be(:empty?)

    other_config = resolve_config(config_path: "config/vite_additional_paths.json")

    expect(other_config.watch_additional_paths).to be == ["config/*"]
  end

  it "auto_build" do
    expect(config.auto_build).to be_falsey

    with_rails_env("development") do |c|
      expect(c.auto_build).to be_truthy
    end

    with_rails_env("test") do |c|
      expect(c.auto_build).to be_truthy
    end

    with_rails_env("staging") do |c|
      expect(c.auto_build).to be_falsey
    end
  end

  it "protocol" do
    expect(config.protocol).to be == "http"
  end

  it "host_with_port" do
    expect(config.port).to be == 3036

    with_rails_env("development") do |c|
      expect(c.port).to be == 3535
      expect(c.host_with_port).to be == "localhost:3535"
    end
  end

  it "to_env" do
    env = config.to_env

    expect(env["VITE_RUBY_ASSET_HOST"]).to be_nil

    Rails.application.config.action_controller.asset_host = "assets-cdn.com"
    env = refresh_config.to_env

    expect(env["VITE_RUBY_ASSET_HOST"]).to be == "assets-cdn.com"
  ensure
    Rails.application.config.action_controller.asset_host = nil
  end

  it "environment_vars" do
    ViteRuby.env.tap(&:clear).merge!(
      "VITE_RUBY_AUTO_BUILD" => "true",
      "VITE_RUBY_HOST" => "example.com",
      "VITE_RUBY_PORT" => "1920",
      "VITE_RUBY_HTTPS" => "true",
      "VITE_RUBY_CONFIG_PATH" => "config/vite_additional_paths.json",
      "VITE_RUBY_BUILD_CACHE_DIR" => "tmp/vitebuild",
      "VITE_RUBY_PUBLIC_DIR" => "pb",
      "VITE_RUBY_PUBLIC_OUTPUT_DIR" => "ft",
      "VITE_RUBY_ASSETS_DIR" => "as",
      "VITE_RUBY_SOURCE_CODE_DIR" => "app",
      "VITE_RUBY_ENTRYPOINTS_DIR" => "frontend/entrypoints",
      "VITE_RUBY_HIDE_BUILD_CONSOLE_OUTPUT" => "true",
      "VITE_RUBY_SKIP_COMPATIBILITY_CHECK" => "true",
    )
    cfg = resolve_config

    expect(cfg.auto_build).to be_truthy
    expect(cfg.host).to be == "example.com"
    expect(cfg.port).to be == 1920
    expect(cfg.https).to be_truthy
    expect(cfg.protocol).to be == "https"
    expect(cfg.config_path).to be == "config/vite_additional_paths.json"
    assert_pathname "tmp/vitebuild", cfg.build_cache_dir
    expect(cfg.public_dir).to be == "pb"
    expect(cfg.public_output_dir).to be == "ft"
    assert_pathname "pb/ft", cfg.build_output_dir
    expect(cfg.assets_dir).to be == "as"
    expect(cfg.source_code_dir).to be == "app"
    expect(cfg.skip_compatibility_check).to be_truthy
    expect(cfg.entrypoints_dir).to be == "frontend/entrypoints"
    assert_pathname "app", cfg.vite_root_dir
    assert_pathname "app/frontend/entrypoints", cfg.resolved_entrypoints_dir
    expect(cfg.hide_build_console_output).to be_truthy
  ensure
    ViteRuby.env.clear
  end

  it "watched_paths" do
    expect(config.source_code_dir).to be == "app/frontend"
    expect(config.additional_entrypoints).to be == ["~/{assets,fonts,icons,images}/**/*"]
    expect(config.watched_paths).to be == [
      "app/frontend/**/*",
      "config/vite.{rb,json}",
      *ViteRuby::Config::DEFAULT_WATCHED_PATHS,
    ]
  end
end
