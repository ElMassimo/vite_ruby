# frozen_string_literal: true

require "test_helper"

class ManifestTest < ViteRuby::Test
  def setup
    super
    ViteRuby::Manifest.instance_eval { public :lookup, :lookup!, :resolve_entry_name }
  end

  def teardown
    ViteRuby::Manifest.instance_eval { private :lookup, :lookup!, :resolve_entry_name }
    super
  end

  delegate :path_for, :lookup, :lookup!, :resolve_entry_name, :vite_client_src, to: "ViteRuby.instance.manifest"

  def test_resolve_entry_name
    assert_equal "entrypoints/application.js", resolve_entry_name("application", type: :javascript)
    assert_equal "entrypoints/application.js", resolve_entry_name("application.js", type: :javascript)
    assert_equal "entrypoints/application.js", resolve_entry_name("application.js")
    assert_equal "entrypoints/application.ts", resolve_entry_name("application", type: :typescript)
    assert_equal "entrypoints/application.ts", resolve_entry_name("application.ts", type: :typescript)

    assert_equal "entrypoints/styles.css", resolve_entry_name("styles", type: :stylesheet)
    assert_equal "entrypoints/styles.css", resolve_entry_name("styles.css", type: :stylesheet)
    assert_equal "entrypoints/styles.css", resolve_entry_name("styles.css")
    assert_equal "entrypoints/styles.scss", resolve_entry_name("styles.scss", type: :stylesheet)

    assert_equal "entrypoints/logo.svg", resolve_entry_name("logo.svg")
    assert_equal "images/logo.svg", resolve_entry_name("images/logo.svg")
    assert_equal "images/logo.svg", resolve_entry_name("~/images/logo.svg")
    assert_equal "favicon.ico", resolve_entry_name("~/favicon.ico")
    assert_equal "../../package.json", resolve_entry_name("/package.json")
    assert_equal "../../images/logo.svg", resolve_entry_name("/images/logo.svg")
    assert_equal "../assets/theme.css", resolve_entry_name("/app/assets/theme.css")

    with_dev_server_running {
      assert_equal "entrypoints/logo.svg", resolve_entry_name("logo.svg")
      assert_equal "images/logo.svg", resolve_entry_name("images/logo.svg")
      assert_equal "images/logo.svg", resolve_entry_name("~/images/logo.svg")
      assert_equal "favicon.ico", resolve_entry_name("~/favicon.ico")
      assert_equal "/@fs#{ViteRuby.config.root}/package.json", resolve_entry_name("/package.json")
      assert_equal "/@fs#{ViteRuby.config.root}/images/logo.svg", resolve_entry_name("/images/logo.svg")
      assert_equal "/@fs#{ViteRuby.config.root}/app/assets/theme.css", resolve_entry_name("/app/assets/theme.css")
    }

    assert_equal "entrypoints/application.js", resolve_entry_name("entrypoints/application.js")
  end

  def test_lookup_exception!
    stub_builder(build_successful: true) {
      asset_file = "calendar.js"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      assert_match "Vite Ruby can't find entrypoints/#{asset_file} in the manifests", error.message
      assert_match '"autoBuild" is set to `false`', error.message

      asset_file = "images/logo.gif"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      assert_match "Vite Ruby can't find #{asset_file} in the manifests", error.message

      asset_file = "/app/styles/theme.css"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      assert_match "Vite Ruby can't find ../styles/theme.css in the manifests", error.message

      asset_file = "~/favicon.ico"
      error = assert_raises_manifest_missing_entry_error { path_for(asset_file) }

      assert_match "Vite Ruby can't find favicon.ico in the manifests", error.message

      assert_match "Manifest files found:\n  #{manifest_path}", error.message
    }
  end

  def test_lookup_exception_when_auto_build
    stub_builder(build_successful: true) {
      asset_file = "calendar.js"

      error = assert_raises_manifest_missing_entry_error(auto_build: true) do
        path_for(asset_file)
      end

      assert_match "Vite Ruby can't find entrypoints/#{asset_file} in the manifests", error.message
      assert_match "The file path is incorrect.", error.message
    }
  end

  def test_lookup_exception_when_build_failed
    error_lines = [
      "SyntaxError: Hero.jsx: Unexpected token (6:6)",
      "  4 |   return <>",
    ]
    stub_builder(build_successful: false, build_errors: error_lines.join("\n")) {
      asset_file = "calendar.js"

      error = assert_raises_manifest_missing_entry_error do
        path_for(asset_file)
      end

      assert_match "Vite Ruby can't find entrypoints/#{asset_file} in the manifests", error.message
      assert_match "The last build failed.", error.message
      assert_match "  #{error_lines[0]}", error.message
      assert_match "  #{error_lines[1]}", error.message
    }
  end

  def test_lookup_with_type_exception!
    asset_file = "calendar"

    error = assert_raises_manifest_missing_entry_error do
      path_for(asset_file, type: :javascript)
    end

    assert_match "Vite Ruby can't find entrypoints/#{asset_file}.js in the manifests", error.message
  end

  def test_lookup_success!
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
            {"file" => prefixed("vendor.0f7c0ec3.js")},
          ],
          "css" => [
            prefixed("vue.ec0a97cc.css"),
          ],
          "assets" => [
            prefixed("logo.322aae0c.svg"),
          ],
        },
        {"file" => prefixed("vendor.0f7c0ec3.js")},
      ],
      "css" => [
        prefixed("app.517bf154.css"),
        prefixed("theme.e6d9734b.css"),
      ],
    }

    assert_equal entry["file"], path_for("main", type: :typescript)
    assert_equal entry, lookup!("main.ts", type: :javascript)
    assert_equal lookup!("main", type: :typescript), lookup!("main.ts", type: :javascript)
    assert_equal lookup!("entrypoints/main", type: :typescript), lookup!("main.ts")
  end

  def test_lookup_success_with_dev_server_running!
    refresh_config(mode: "development")
    with_dev_server_running {
      entry = {"file" => "/vite-dev/entrypoints/application.js"}

      assert_equal entry, lookup!("application.js", type: :javascript)
      assert_equal entry, lookup!("entrypoints/application.js")

      assert_equal "/vite-dev/entrypoints/application.ts",
        path_for("application", type: :typescript)

      assert_equal "/vite-dev/entrypoints/styles.css",
        path_for("styles", type: :stylesheet)

      assert_equal "/vite-dev/image/logo.png",
        path_for("image/logo.png")

      assert_equal "/vite-dev/logo.png",
        path_for("~/logo.png")

      assert_equal "/vite-dev/@fs#{ViteRuby.config.root}/app/assets/theme.css",
        path_for("/app/assets/theme", type: :stylesheet)
    }
  end

  def test_vite_client_src
    refresh_config(mode: "development")

    assert_nil vite_client_src

    with_dev_server_running {
      assert_equal "/vite-dev/@vite/client", vite_client_src
    }

    refresh_config(asset_host: "http://example.com", mode: "development")

    with_dev_server_running {
      assert_equal "http://example.com/vite-dev/@vite/client", vite_client_src
    }
  end

  def test_lookup_nil
    assert_nil lookup("foo.js")
  end

  def test_lookup_nested_entrypoint
    # Because it's a nested dir, it won't be prefixed automatically and it must
    # be explicitly disambiguated.
    assert_nil lookup("frameworks/vue.js")

    file = prefixed("vue.3002ada6.js")

    assert_equal file, path_for("entrypoints/frameworks/vue.js")
    assert_equal file, path_for("~/entrypoints/frameworks/vue.js")
    assert_equal lookup("~/entrypoints/frameworks/vue", type: :javascript), lookup("entrypoints/frameworks/vue.js")
  end

  def test_path_for_assets
    assert_equal prefixed("logo.f42fb7ea.png"), path_for("images/logo.png")
    assert_equal prefixed("logo.f42fb7ea.png"), path_for("~/images/logo.png")

    assert_equal prefixed("external.d1ae13f1.js"), path_for("/app/assets/external", type: :javascript)
    assert_equal prefixed("logo.03d6d6da.png"), path_for("/app/assets/logo.png")
    assert_equal prefixed("theme.e6d9734b.css"), path_for("/app/assets/theme", type: :stylesheet)
  end

  def test_lookup_success
    entry = {"file" => prefixed("app.517bf154.css"), "src" => "entrypoints/app.css"}

    assert_equal entry, lookup("app.css")
    assert_equal entry, lookup("app.css", type: :stylesheet)
    assert_equal entry, lookup("app", type: :stylesheet)

    entry = {"file" => prefixed("logo.322aae0c.svg"), "src" => "images/logo.svg"}

    assert_equal entry, lookup("images/logo.svg")
  end

private

  def assert_raises_manifest_missing_entry_error(auto_build: false, &block)
    error = nil

    ViteRuby.config.stub :auto_build, auto_build do
      error = assert_raises(ViteRuby::MissingEntrypointError, &block)
    end
    error
  end

  def manifest_path
    "public/vite-production/.vite/manifest.json"
  end

  def prefixed(file)
    "/vite-production/assets/#{file}"
  end
end
