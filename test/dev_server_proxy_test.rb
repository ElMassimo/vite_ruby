# frozen_string_literal: true

require "test_helper"

class DevServerProxyTest < ViteRuby::Test
  include Rack::Test::Methods

  def app
    # Capture all changes to the env made by the proxy.
    capture_app = Rack::Builder.new.run(->(env) {
      [200, {"Content-Type" => "application/json"}, env.to_json]
    })
    # Avoid actually using the proxy.
    if RUBY_VERSION.start_with?("2.4")
      Rack::Proxy.send(:remove_method, :perform_request) if Rack::Proxy.method_defined?(:perform_request)
      Rack::Proxy.send(:define_method, :perform_request) { |env| capture_app.call(env) }
    else
      Rack::Proxy.remove_method(:perform_request)
      Rack::Proxy.define_method(:perform_request) { |env| capture_app.call(env) }
    end

    ViteRuby::DevServerProxy.new(capture_app)
  end

  def test_non_asset
    get_with_dev_server_running "/"

    assert_not_forwarded
  end

  def test_non_vite_asset
    get_with_dev_server_running "/fake_import.js"

    assert_not_forwarded
  end

  def test_vite_asset
    get_with_dev_server_running "/vite-production/application.js"

    assert_forwarded to: "/vite-production/application.js"
  end

  def test_vite_client
    get_with_dev_server_running "/@vite/client"

    assert_not_forwarded
  end

  def test_vite_client_with_empty_prefix
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/@vite/client"

    assert_forwarded to: "/@vite/client"
  end

  def test_vite_import
    get_with_dev_server_running "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"

    assert_not_forwarded
  end

  def test_vite_import_with_empty_prefix
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"

    assert_forwarded to: "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"
  end

  def test_hmr_for_stylesheet
    get_with_dev_server_running "/entrypoints/colored.css?t=1611322562923"

    assert_forwarded to: "/entrypoints/colored.css?t=1611322562923"
  end

  def test_hmr_for_imported_entrypoint
    get_with_dev_server_running "/entrypoints/colored.css?import&t=1611322562923"

    assert_forwarded to: "/entrypoints/colored.css?import&t=1611322562923"
  end

  def test_entrypoint_imported_from_entrypoint
    header "Referer", "http://localhost:3000/vite-production/application.js"
    get_with_dev_server_running "/entrypoints/example_import.js"

    assert_forwarded to: "/entrypoints/example_import.js"
  end

  def test_scss_with_extra_css
    get_with_dev_server_running "/vite-production/entrypoints/sassy.scss.css"

    assert_forwarded to: "/vite-production/entrypoints/sassy.scss"
  end

  def test_stylus_with_extra_css
    get_with_dev_server_running "/vite-production/entrypoints/sassy.stylus.css"

    assert_forwarded to: "/vite-production/entrypoints/sassy.stylus"
  end

  def test_min_css
    get_with_dev_server_running "/vite-production/colored.min.css"

    assert_forwarded to: "/vite-production/colored.min.css"
  end

  def test_module_css
    get_with_dev_server_running "/vite-production/colored.module.css"

    assert_forwarded to: "/vite-production/colored.module.css"
  end

  def test_random_extension_css
    get_with_dev_server_running "/vite-production/colored.bubble.css"

    assert_forwarded to: "/vite-production/colored.bubble.css"
  end

  def test_without_dev_server_running
    get "/vite-production/application.js"

    assert_not_forwarded

    get "/entrypoints/colored.css?import&t=1611322562923"

    assert_not_forwarded

    header "Referer", "http://localhost:3000/vite-production/application.js"
    get "/entrypoints/example_import.js"

    assert_not_forwarded
  end

  def test_empty_public_output_dir
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/"

    assert_not_forwarded

    get_with_dev_server_running "/entrypoints/application.js"

    assert_forwarded to: "/entrypoints/application.js"

    get_with_dev_server_running "/entrypoints/sassy.scss.css"

    assert_forwarded to: "/entrypoints/sassy.scss"
  end

private

  def get_with_dev_server_running(*args)
    with_dev_server_running {
      get(*args)
    }
  end

  def assert_not_forwarded
    assert_predicate last_response, :ok?
    env = JSON.parse(last_response.body)

    assert_nil env["HTTP_X_FORWARDED_HOST"]
    assert_nil env["HTTP_X_FORWARDED_PORT"]
  end

  def assert_forwarded(to: nil)
    assert_predicate last_response, :ok?
    env = JSON.parse(last_response.body)

    assert_equal ViteRuby.config.host, env["HTTP_X_FORWARDED_HOST"]
    assert_equal ViteRuby.config.port, Integer(env["HTTP_X_FORWARDED_PORT"])

    return unless to

    path, query = to.split("?")

    assert_equal path, env["PATH_INFO"]
    assert_equal query.to_s, env["QUERY_STRING"].to_s
    assert_equal to, env["REQUEST_URI"]
  end
end
