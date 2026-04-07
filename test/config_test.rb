# frozen_string_literal: true

require "test_helper"

describe "Config" do
  def expand_path(path)
    File.expand_path(Pathname.new(__dir__).join(path).to_s)
  end

  def assert_path(expected, actual)
    expect(actual.to_s) == expand_path(expected)
  end

  def assert_pathname(expected, actual)
    expect(actual) == Pathname.new(expand_path("test_app/#{expected}"))
  end

  def resolve_config(mode: "production", root: path_to_test_app, **attrs)
    ViteRuby::Config.resolve_config(mode: mode, root: root, **attrs)
  end

  def setup
    super
    @config = resolve_config
  end

  test "matching default config json" do
    root = Pathname.new(__dir__).join("..")
    expect(root.join("vite-plugin-ruby/default.vite.json").read) == root.join("vite_ruby/default.vite.json").read
  end

  test "source code dir" do
    expect(@config.source_code_dir) == "app/frontend"
  end

  test "entrypoints dir" do
    assert_path "test_app/app/frontend/entrypoints", @config.resolved_entrypoints_dir
  end

  test "vite root dir" do
    assert_path "test_app/app/frontend", @config.vite_root_dir
  end

  test "public dir" do
    expect(@config.public_dir) == "public"
  end

  test "build output dir" do
    assert_path "test_app/public/vite-production", @config.build_output_dir

    @config = resolve_config(config_path: "config/vite_public_dir.json")

    assert_path "public/vite", @config.build_output_dir
  end

  test "ruby config file" do
    expect(@config.to_env["EXAMPLE_PATH"]) == nil

    refresh_config(config_path: "config/vite_public_dir.json")

    expect(ViteRuby.config.public_output_dir) == "from_ruby"
    expect(ViteRuby.config.to_env["EXAMPLE_PATH"]) == Gem.loaded_specs["rails"].full_gem_path
  end

  test "manifest path" do
    assert_path "test_app/public/vite-production/.vite/manifest.json", @config.manifest_paths.first
  end

  test "build cache dir" do
    assert_path "test_app/tmp/cache/vite", @config.build_cache_dir
  end

  test "watch additional paths" do
    expect(@config.watch_additional_paths).to_be(:empty?)
    @config = resolve_config(config_path: "config/vite_additional_paths.json")

    expect(@config.watch_additional_paths) == ["config/*"]
  end

  test "auto build" do
    refute(@config.auto_build)

    with_rails_env("development") do |config|
      assert(config.auto_build)
    end

    with_rails_env("test") do |config|
      assert(config.auto_build)
    end

    with_rails_env("staging") do |config|
      refute(config.auto_build)
    end
  end

  test "protocol" do
    expect(@config.protocol) == "http"
  end

  test "host with port" do
    expect(@config.port) == 3036

    with_rails_env("development") do |config|
      expect(config.port) == 3535
      expect(config.host_with_port) == "localhost:3535"
    end
  end

  test "to env" do
    env = @config.to_env

    expect(env["VITE_RUBY_ASSET_HOST"]) == nil

    Rails.application.config.action_controller.asset_host = "assets-cdn.com"
    env = refresh_config.to_env

    expect(env["VITE_RUBY_ASSET_HOST"]) == "assets-cdn.com"
  ensure
    Rails.application.config.action_controller.asset_host = nil
  end

  test "environment vars" do
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
    @config = resolve_config

    assert(@config.auto_build)
    expect(@config.host) == "example.com"
    expect(@config.port) == 1920
    assert(@config.https)
    expect(@config.protocol) == "https"
    expect(@config.config_path) == "config/vite_additional_paths.json"
    assert_pathname "tmp/vitebuild", @config.build_cache_dir
    expect(@config.public_dir) == "pb"
    expect(@config.public_output_dir) == "ft"
    assert_pathname "pb/ft", @config.build_output_dir
    expect(@config.assets_dir) == "as"
    expect(@config.source_code_dir) == "app"
    assert(@config.skip_compatibility_check)
    expect(@config.entrypoints_dir) == "frontend/entrypoints"
    assert_pathname "app", @config.vite_root_dir
    assert_pathname "app/frontend/entrypoints", @config.resolved_entrypoints_dir
    assert(@config.hide_build_console_output)
  ensure
    ViteRuby.env.clear
  end

  test "watched paths" do
    expect(@config.source_code_dir) == "app/frontend"
    expect(@config.additional_entrypoints) == ["~/{assets,fonts,icons,images}/**/*"]
    expect(@config.watched_paths) == [
      "app/frontend/**/*",
      "config/vite.{rb,json}",
      *ViteRuby::Config::DEFAULT_WATCHED_PATHS,
    ]
  end
end
