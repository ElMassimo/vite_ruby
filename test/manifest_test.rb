# frozen_string_literal: true

require "test_helper"

describe "Manifest" do
  delegate :path_for, :lookup, :lookup!, :resolve_entry_name, :vite_client_src, to: "ViteRuby.instance.manifest"

  def setup
    super
    ViteRuby::Manifest.instance_eval { public :lookup, :lookup!, :resolve_entry_name }
  end

  def teardown
    ViteRuby::Manifest.instance_eval { private :lookup, :lookup!, :resolve_entry_name }
    super
  end

  def assert_raises_manifest_missing_entry_error(auto_build: false, &block)
    error = nil
    ViteRuby.config.stub(:auto_build, auto_build) do
        yield
    rescue ViteRuby::MissingEntrypointError => e
        error = e
    end
    raise "Expected ViteRuby::MissingEntrypointError but nothing was raised" unless error
    error
  end

  def manifest_path
    "public/vite-production/.vite/manifest.json"
  end

  def prefixed(file)
    "/vite-production/assets/#{file}"
  end

  test "resolve entry name" do
    expect(resolve_entry_name("application", type: :javascript)) == "entrypoints/application.js"
    expect(resolve_entry_name("application.js", type: :javascript)) == "entrypoints/application.js"
    expect(resolve_entry_name("application.js")) == "entrypoints/application.js"
    expect(resolve_entry_name("application", type: :typescript)) == "entrypoints/application.ts"
    expect(resolve_entry_name("application.ts", type: :typescript)) == "entrypoints/application.ts"

    expect(resolve_entry_name("styles", type: :stylesheet)) == "entrypoints/styles.css"
    expect(resolve_entry_name("styles.css", type: :stylesheet)) == "entrypoints/styles.css"
    expect(resolve_entry_name("styles.css")) == "entrypoints/styles.css"
    expect(resolve_entry_name("styles.scss", type: :stylesheet)) == "entrypoints/styles.scss"

    expect(resolve_entry_name("logo.svg")) == "entrypoints/logo.svg"
    expect(resolve_entry_name("images/logo.svg")) == "images/logo.svg"
    expect(resolve_entry_name("~/images/logo.svg")) == "images/logo.svg"
    expect(resolve_entry_name("~/favicon.ico")) == "favicon.ico"
    expect(resolve_entry_name("/package.json")) == "../../package.json"
    expect(resolve_entry_name("/images/logo.svg")) == "../../images/logo.svg"
    expect(resolve_entry_name("/app/assets/theme.css")) == "../assets/theme.css"

    with_dev_server_running {
      expect(resolve_entry_name("logo.svg")) == "entrypoints/logo.svg"
      expect(resolve_entry_name("images/logo.svg")) == "images/logo.svg"
      expect(resolve_entry_name("~/images/logo.svg")) == "images/logo.svg"
      expect(resolve_entry_name("~/favicon.ico")) == "favicon.ico"
      expect(resolve_entry_name("/package.json")) == "/@fs#{ViteRuby.config.root}/package.json"
      expect(resolve_entry_name("/images/logo.svg")) == "/@fs#{ViteRuby.config.root}/images/logo.svg"
      expect(resolve_entry_name("/app/assets/theme.css")) == "/@fs#{ViteRuby.config.root}/app/assets/theme.css"
    }

    expect(resolve_entry_name("entrypoints/application.js")) == "entrypoints/application.js"
  end

  test "lookup exception!" do
    stub_builder(build_successful: true) {
      asset_file = "calendar.js"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      expect(error.message).to_include("Vite Ruby can't find entrypoints/#{asset_file} in the manifests")
      expect(error.message).to_include('"autoBuild" is set to `false`')

      asset_file = "images/logo.gif"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      expect(error.message).to_include("Vite Ruby can't find #{asset_file} in the manifests")

      asset_file = "/app/styles/theme.css"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      expect(error.message).to_include("Vite Ruby can't find ../styles/theme.css in the manifests")

      asset_file = "~/favicon.ico"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      expect(error.message).to_include("Vite Ruby can't find favicon.ico in the manifests")
      expect(error.message).to_include("Manifest files found:\n  #{manifest_path}")
    }
  end

  test "lookup exception when auto build" do
    stub_builder(build_successful: true) {
      asset_file = "calendar.js"
      error = assert_raises_manifest_missing_entry_error(auto_build: true) { path_for(asset_file) }

      expect(error.message).to_include("Vite Ruby can't find entrypoints/#{asset_file} in the manifests")
      expect(error.message).to_include("The file path is incorrect.")
    }
  end

  test "lookup exception when build failed" do
    error_lines = [
      "SyntaxError: Hero.jsx: Unexpected token (6:6)",
      "  4 |   return <>",
    ]
    stub_builder(build_successful: false, build_errors: error_lines.join("\n")) {
      asset_file = "calendar.js"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      expect(error.message).to_include("Vite Ruby can't find entrypoints/#{asset_file} in the manifests")
      expect(error.message).to_include("The last build failed.")
      expect(error.message).to_include("  #{error_lines[0]}")
      expect(error.message).to_include("  #{error_lines[1]}")
    }
  end

  test "lookup with type exception!" do
    asset_file = "calendar"
    error = assert_raises_manifest_missing_entry_error { path_for(asset_file, type: :javascript) }

    expect(error.message).to_include("Vite Ruby can't find entrypoints/#{asset_file}.js in the manifests")
  end

  test "lookup success!" do
    vendor_chunk = {
      "file" => prefixed("vendor.0f7c0ec3.js"),
      "css" => [prefixed("vue.ec0a97cc.css")],
    }
    entry = {
      "file" => prefixed("main.9dcad042.js"),
      "src" => "entrypoints/main.ts",
      "isEntry" => true,
      "imports" => [
        {"file" => prefixed("log.818edfb8.js")},
        {
          "file" => prefixed("vue.3002ada6.js"),
          "src" => "entrypoints/frameworks/vue.js",
          "isEntry" => true,
          "imports" => [vendor_chunk],
          "assets" => [prefixed("logo.322aae0c.svg")],
        },
      ],
      "css" => [
        prefixed("app.517bf154.css"),
        prefixed("theme.e6d9734b.css"),
      ],
    }

    expect(path_for("main", type: :typescript)) == entry["file"]
    expect(lookup!("main.ts", type: :javascript)) == entry
    expect(lookup!("main", type: :typescript)) == lookup!("main.ts", type: :javascript)
    expect(lookup!("entrypoints/main", type: :typescript)) == lookup!("main.ts")
  end

  test "lookup success with dev server running!" do
    refresh_config(mode: "development")
    with_dev_server_running {
      entry = {"file" => "/vite-dev/entrypoints/application.js"}

      expect(lookup!("application.js", type: :javascript)) == entry
      expect(lookup!("entrypoints/application.js")) == entry

      expect(path_for("application", type: :typescript)) == "/vite-dev/entrypoints/application.ts"
      expect(path_for("styles", type: :stylesheet)) == "/vite-dev/entrypoints/styles.css"
      expect(path_for("image/logo.png")) == "/vite-dev/image/logo.png"
      expect(path_for("~/logo.png")) == "/vite-dev/logo.png"
      expect(path_for("/app/assets/theme", type: :stylesheet)) == "/vite-dev/@fs#{ViteRuby.config.root}/app/assets/theme.css"
    }
  end

  test "vite client src" do
    refresh_config(mode: "development")

    expect(vite_client_src) == nil

    with_dev_server_running {
      expect(vite_client_src) == "/vite-dev/@vite/client"
    }

    refresh_config(asset_host: "http://example.com", mode: "development")

    with_dev_server_running {
      expect(vite_client_src) == "http://example.com/vite-dev/@vite/client"
    }
  end

  test "lookup nil" do
    expect(lookup("foo.js")) == nil
  end

  test "lookup nested entrypoint" do
    expect(lookup("frameworks/vue.js")) == nil

    file = prefixed("vue.3002ada6.js")

    expect(path_for("entrypoints/frameworks/vue.js")) == file
    expect(path_for("~/entrypoints/frameworks/vue.js")) == file
    expect(lookup("~/entrypoints/frameworks/vue", type: :javascript)) == lookup("entrypoints/frameworks/vue.js")
  end

  test "path for assets" do
    expect(path_for("images/logo.png")) == prefixed("logo.f42fb7ea.png")
    expect(path_for("~/images/logo.png")) == prefixed("logo.f42fb7ea.png")

    expect(path_for("/app/assets/external", type: :javascript)) == prefixed("external.d1ae13f1.js")
    expect(path_for("/app/assets/logo.png")) == prefixed("logo.03d6d6da.png")
    expect(path_for("/app/assets/theme", type: :stylesheet)) == prefixed("theme.e6d9734b.css")
  end

  test "lookup success" do
    entry = {"file" => prefixed("app.517bf154.css"), "src" => "entrypoints/app.css"}

    expect(lookup("app.css")) == entry
    expect(lookup("app.css", type: :stylesheet)) == entry
    expect(lookup("app", type: :stylesheet)) == entry

    entry = {"file" => prefixed("logo.322aae0c.svg"), "src" => "images/logo.svg"}
    expect(lookup("images/logo.svg")) == entry
  end
end
