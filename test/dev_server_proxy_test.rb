# frozen_string_literal: true

require "test_helper"

describe "DevServerProxy" do
  include Rack::Test::Methods

  def app
    # Capture all changes to the env made by the proxy.
    capture_app = ->(env) {
      [200, {"Content-Type" => "application/json"}, env.to_json]
    }
    # Avoid actually using the proxy (patch once, guard against double-removal).
    Rack::Proxy.remove_method(:perform_request) rescue nil
    Rack::Proxy.define_method(:perform_request) { |env| capture_app.call(env) }

    ViteRuby::DevServerProxy.new(capture_app)
  end

  def setup
    super
    @_rack_test_sessions = {}
    @_rack_test_current_session = nil
  end

  def get_with_dev_server_running(*args)
    with_dev_server_running { get(*args) }
  end

  def assert_not_forwarded
    expect(last_response).to_be(:ok?)
    env = JSON.parse(last_response.body)

    expect(env["HTTP_X_FORWARDED_HOST"]) == nil
    expect(env["HTTP_X_FORWARDED_PORT"]) == nil
  end

  def assert_forwarded(to: nil)
    expect(last_response).to_be(:ok?)
    env = JSON.parse(last_response.body)

    expect(env["HTTP_X_FORWARDED_HOST"]) == ViteRuby.config.host
    expect(Integer(env["HTTP_X_FORWARDED_PORT"])) == ViteRuby.config.port

    return unless to

    path, query = to.split("?")

    expect(env["PATH_INFO"]) == path
    expect(env["QUERY_STRING"].to_s) == query.to_s
    expect(env["REQUEST_URI"]) == to
  end

  test "non asset" do
    get_with_dev_server_running "/"
    assert_not_forwarded
  end

  test "non vite asset" do
    get_with_dev_server_running "/fake_import.js"
    assert_not_forwarded
  end

  test "vite asset" do
    get_with_dev_server_running "/vite-production/application.js"
    assert_forwarded to: "/vite-production/application.js"
  end

  test "vite client" do
    get_with_dev_server_running "/@vite/client"
    assert_not_forwarded
  end

  test "vite client with empty prefix" do
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/@vite/client"
    assert_forwarded to: "/@vite/client"
  end

  test "vite import" do
    get_with_dev_server_running "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"
    assert_not_forwarded
  end

  test "vite import with empty prefix" do
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"
    assert_forwarded to: "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"
  end

  test "hmr for stylesheet" do
    get_with_dev_server_running "/entrypoints/colored.css?t=1611322562923"
    assert_forwarded to: "/entrypoints/colored.css?t=1611322562923"
  end

  test "hmr for imported entrypoint" do
    get_with_dev_server_running "/entrypoints/colored.css?import&t=1611322562923"
    assert_forwarded to: "/entrypoints/colored.css?import&t=1611322562923"
  end

  test "entrypoint imported from entrypoint" do
    header "Referer", "http://localhost:3000/vite-production/application.js"
    get_with_dev_server_running "/entrypoints/example_import.js"
    assert_forwarded to: "/entrypoints/example_import.js"
  end

  test "scss with extra css" do
    get_with_dev_server_running "/vite-production/entrypoints/sassy.scss.css"
    assert_forwarded to: "/vite-production/entrypoints/sassy.scss"
  end

  test "stylus with extra css" do
    get_with_dev_server_running "/vite-production/entrypoints/sassy.stylus.css"
    assert_forwarded to: "/vite-production/entrypoints/sassy.stylus"
  end

  test "min css" do
    get_with_dev_server_running "/vite-production/colored.min.css"
    assert_forwarded to: "/vite-production/colored.min.css"
  end

  test "module css" do
    get_with_dev_server_running "/vite-production/colored.module.css"
    assert_forwarded to: "/vite-production/colored.module.css"
  end

  test "random extension css" do
    get_with_dev_server_running "/vite-production/colored.bubble.css"
    assert_forwarded to: "/vite-production/colored.bubble.css"
  end

  test "without dev server running" do
    get "/vite-production/application.js"
    assert_not_forwarded

    get "/entrypoints/colored.css?import&t=1611322562923"
    assert_not_forwarded

    header "Referer", "http://localhost:3000/vite-production/application.js"
    get "/entrypoints/example_import.js"
    assert_not_forwarded
  end

  test "empty public output dir" do
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/"
    assert_not_forwarded

    get_with_dev_server_running "/entrypoints/application.js"
    assert_forwarded to: "/entrypoints/application.js"

    get_with_dev_server_running "/entrypoints/sassy.scss.css"
    assert_forwarded to: "/entrypoints/sassy.scss"
  end
end
