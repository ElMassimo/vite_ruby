# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ViteRuby::Manifest" do
  before do
    ViteRuby::Manifest.instance_eval { public :lookup, :lookup!, :resolve_entry_name }
  end

  after do
    ViteRuby::Manifest.instance_eval { private :lookup, :lookup!, :resolve_entry_name }
  end

  delegate :path_for, :lookup, :lookup!, :resolve_entry_name, :vite_client_src, to: "ViteRuby.instance.manifest"

  it "resolve_entry_name" do
    expect(resolve_entry_name("application", type: :javascript)).to eq("entrypoints/application.js")
    expect(resolve_entry_name("application.js", type: :javascript)).to eq("entrypoints/application.js")
    expect(resolve_entry_name("application.js")).to eq("entrypoints/application.js")
    expect(resolve_entry_name("application", type: :typescript)).to eq("entrypoints/application.ts")
    expect(resolve_entry_name("application.ts", type: :typescript)).to eq("entrypoints/application.ts")

    expect(resolve_entry_name("styles", type: :stylesheet)).to eq("entrypoints/styles.css")
    expect(resolve_entry_name("styles.css", type: :stylesheet)).to eq("entrypoints/styles.css")
    expect(resolve_entry_name("styles.css")).to eq("entrypoints/styles.css")
    expect(resolve_entry_name("styles.scss", type: :stylesheet)).to eq("entrypoints/styles.scss")

    expect(resolve_entry_name("logo.svg")).to eq("entrypoints/logo.svg")
    expect(resolve_entry_name("images/logo.svg")).to eq("images/logo.svg")
    expect(resolve_entry_name("~/images/logo.svg")).to eq("images/logo.svg")
    expect(resolve_entry_name("~/favicon.ico")).to eq("favicon.ico")
    expect(resolve_entry_name("/package.json")).to eq("../../package.json")
    expect(resolve_entry_name("/images/logo.svg")).to eq("../../images/logo.svg")
    expect(resolve_entry_name("/app/assets/theme.css")).to eq("../assets/theme.css")

    with_dev_server_running {
      expect(resolve_entry_name("logo.svg")).to eq("entrypoints/logo.svg")
      expect(resolve_entry_name("images/logo.svg")).to eq("images/logo.svg")
      expect(resolve_entry_name("~/images/logo.svg")).to eq("images/logo.svg")
      expect(resolve_entry_name("~/favicon.ico")).to eq("favicon.ico")
      expect(resolve_entry_name("/package.json")).to eq("/@fs#{ViteRuby.config.root}/package.json")
      expect(resolve_entry_name("/images/logo.svg")).to eq("/@fs#{ViteRuby.config.root}/images/logo.svg")
      expect(resolve_entry_name("/app/assets/theme.css")).to eq("/@fs#{ViteRuby.config.root}/app/assets/theme.css")
    }

    expect(resolve_entry_name("entrypoints/application.js")).to eq("entrypoints/application.js")
  end

  it "lookup_exception!" do
    stub_builder(build_successful: true) {
      asset_file = "calendar.js"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      expect(error.message).to include("Vite Ruby can't find entrypoints/#{asset_file} in the manifests")
      expect(error.message).to include('"autoBuild" is set to `false`')

      asset_file = "images/logo.gif"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }
      expect(error.message).to include("Vite Ruby can't find #{asset_file} in the manifests")

      asset_file = "/app/styles/theme.css"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }
      expect(error.message).to include("Vite Ruby can't find ../styles/theme.css in the manifests")

      asset_file = "~/favicon.ico"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }
      expect(error.message).to include("Vite Ruby can't find favicon.ico in the manifests")
      expect(error.message).to include("Manifest files found:\n  #{manifest_path}")
    }
  end

  it "lookup_exception_when_auto_build" do
    stub_builder(build_successful: true) {
      asset_file = "calendar.js"
      error = assert_raises_manifest_missing_entry_error(auto_build: true) do
        path_for(asset_file)
      end

      expect(error.message).to include("Vite Ruby can't find entrypoints/#{asset_file} in the manifests")
      expect(error.message).to include("The file path is incorrect.")
    }
  end

  it "lookup_exception_when_build_failed" do
    error_lines = [
      "SyntaxError: Hero.jsx: Unexpected token (6:6)",
      "  4 |   return <>",
    ]
    stub_builder(build_successful: false, build_errors: error_lines.join("\n")) {
      asset_file = "calendar.js"
      error = assert_raises_manifest_missing_entry_error do
        path_for(asset_file)
      end

      expect(error.message).to include("Vite Ruby can't find entrypoints/#{asset_file} in the manifests")
      expect(error.message).to include("The last build failed.")
      expect(error.message).to include("  #{error_lines[0]}")
      expect(error.message).to include("  #{error_lines[1]}")
    }
  end

  it "lookup_with_type_exception!" do
    asset_file = "calendar"
    error = assert_raises_manifest_missing_entry_error do
      path_for(asset_file, type: :javascript)
    end

    expect(error.message).to include("Vite Ruby can't find entrypoints/#{asset_file}.js in the manifests")
  end

  it "lookup_success!" do
    vendor_chunk = {
      "file" => prefixed("vendor.0f7c0ec3.js"),
      "css" => [
        prefixed("vue.ec0a97cc.css"),
      ],
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
          "imports" => [
            vendor_chunk,
          ],
          "assets" => [
            prefixed("logo.322aae0c.svg"),
          ],
        },
      ],
      "css" => [
        prefixed("app.517bf154.css"),
        prefixed("theme.e6d9734b.css"),
      ],
    }

    expect(path_for("main", type: :typescript)).to eq(entry["file"])
    expect(lookup!("main.ts", type: :javascript)).to eq(entry)
    expect(lookup!("main", type: :typescript)).to eq(lookup!("main.ts", type: :javascript))
    expect(lookup!("entrypoints/main", type: :typescript)).to eq(lookup!("main.ts"))
  end

  it "lookup_success_with_dev_server_running!" do
    refresh_config(mode: "development")
    with_dev_server_running {
      entry = {"file" => "/vite-dev/entrypoints/application.js"}

      expect(lookup!("application.js", type: :javascript)).to eq(entry)
      expect(lookup!("entrypoints/application.js")).to eq(entry)

      expect(path_for("application", type: :typescript)).to eq("/vite-dev/entrypoints/application.ts")
      expect(path_for("styles", type: :stylesheet)).to eq("/vite-dev/entrypoints/styles.css")
      expect(path_for("image/logo.png")).to eq("/vite-dev/image/logo.png")
      expect(path_for("~/logo.png")).to eq("/vite-dev/logo.png")
      expect(path_for("/app/assets/theme", type: :stylesheet)).to eq("/vite-dev/@fs#{ViteRuby.config.root}/app/assets/theme.css")
    }
  end

  it "vite_client_src" do
    refresh_config(mode: "development")

    expect(vite_client_src).to be_nil

    with_dev_server_running {
      expect(vite_client_src).to eq("/vite-dev/@vite/client")
    }

    refresh_config(asset_host: "http://example.com", mode: "development")

    with_dev_server_running {
      expect(vite_client_src).to eq("http://example.com/vite-dev/@vite/client")
    }
  end

  it "lookup_nil" do
    expect(lookup("foo.js")).to be_nil
  end

  it "lookup_nested_entrypoint" do
    expect(lookup("frameworks/vue.js")).to be_nil

    file = prefixed("vue.3002ada6.js")

    expect(path_for("entrypoints/frameworks/vue.js")).to eq(file)
    expect(path_for("~/entrypoints/frameworks/vue.js")).to eq(file)
    expect(lookup("~/entrypoints/frameworks/vue", type: :javascript)).to eq(lookup("entrypoints/frameworks/vue.js"))
  end

  it "path_for_assets" do
    expect(path_for("images/logo.png")).to eq(prefixed("logo.f42fb7ea.png"))
    expect(path_for("~/images/logo.png")).to eq(prefixed("logo.f42fb7ea.png"))

    expect(path_for("/app/assets/external", type: :javascript)).to eq(prefixed("external.d1ae13f1.js"))
    expect(path_for("/app/assets/logo.png")).to eq(prefixed("logo.03d6d6da.png"))
    expect(path_for("/app/assets/theme", type: :stylesheet)).to eq(prefixed("theme.e6d9734b.css"))
  end

  it "lookup_success" do
    entry = {"file" => prefixed("app.517bf154.css"), "src" => "entrypoints/app.css"}

    expect(lookup("app.css")).to eq(entry)
    expect(lookup("app.css", type: :stylesheet)).to eq(entry)
    expect(lookup("app", type: :stylesheet)).to eq(entry)

    entry = {"file" => prefixed("logo.322aae0c.svg"), "src" => "images/logo.svg"}
    expect(lookup("images/logo.svg")).to eq(entry)
  end

private

  def assert_raises_manifest_missing_entry_error(auto_build: false)
    allow(ViteRuby.config).to receive(:auto_build).and_return(auto_build)
    begin
      yield
      raise "Expected ViteRuby::MissingEntrypointError"
    rescue ViteRuby::MissingEntrypointError => e
      e
    end
  end

  def manifest_path
    "public/vite-production/.vite/manifest.json"
  end

  def prefixed(file)
    "/vite-production/assets/#{file}"
  end
end
