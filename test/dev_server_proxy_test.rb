# frozen_string_literal: true

require "test_helper"

describe "DevServerProxyTest" do
  include ViteRubyTestHelpers
  include Rack::Test::Methods

  let(:app) {
    # Capture all changes to the env made by the proxy.
    capture_app = ->(env) {
      [200, {"Content-Type" => "application/json"}, env.to_json]
    }
    # Avoid actually using the proxy.
    if RUBY_VERSION.start_with?("2.4")
      Rack::Proxy.send(:remove_method, :perform_request) if Rack::Proxy.method_defined?(:perform_request)
      Rack::Proxy.send(:define_method, :perform_request) { |env| capture_app.call(env) }
    else
      Rack::Proxy.remove_method(:perform_request)
      Rack::Proxy.define_method(:perform_request) { |env| capture_app.call(env) }
    end

    ViteRuby::DevServerProxy.new(capture_app)
  }

  it "non_asset" do
    get_with_dev_server_running "/"

    assert_not_forwarded
  end

  it "non_vite_asset" do
    get_with_dev_server_running "/fake_import.js"

    assert_not_forwarded
  end

  it "vite_asset" do
    get_with_dev_server_running "/vite-production/application.js"

    assert_forwarded to: "/vite-production/application.js"
  end

  it "vite_client" do
    get_with_dev_server_running "/@vite/client"

    assert_not_forwarded
  end

  it "vite_client_with_empty_prefix" do
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/@vite/client"

    assert_forwarded to: "/@vite/client"
  end

  it "vite_import" do
    get_with_dev_server_running "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"

    assert_not_forwarded
  end

  it "vite_import_with_empty_prefix" do
    refresh_config(public_output_dir: "")
    get_with_dev_server_running "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"

    assert_forwarded to: "/@fs//package/example/app/frontend/App.vue?import&t=1611322300214&vue&type=style&index=0&lang.css"
  end

  it "hmr_for_stylesheet" do
    get_with_dev_server_running "/entrypoints/colored.css?t=1611322562923"

    assert_forwarded to: "/entrypoints/colored.css?t=1611322562923"
  end

  it "hmr_for_imported_entrypoint" do
    get_with_dev_server_running "/entrypoints/colored.css?import&t=1611322562923"

    assert_forwarded to: "/entrypoints/colored.css?import&t=1611322562923"
  end

  it "entrypoint_imported_from_entrypoint" do
    header "Referer", "http://localhost:3000/vite-production/application.js"
    get_with_dev_server_running "/entrypoints/example_import.js"

    assert_forwarded to: "/entrypoints/example_import.js"
  end

  it "scss_with_extra_css" do
    get_with_dev_server_running "/vite-production/entrypoints/sassy.scss.css"

    assert_forwarded to: "/vite-production/entrypoints/sassy.scss"
  end

  it "stylus_with_extra_css" do
    get_with_dev_server_running "/vite-production/entrypoints/sassy.stylus.css"

    assert_forwarded to: "/vite-production/entrypoints/sassy.stylus"
  end

  it "min_css" do
    get_with_dev_server_running "/vite-production/colored.min.css"

    assert_forwarded to: "/vite-production/colored.min.css"
  end

  it "module_css" do
    get_with_dev_server_running "/vite-production/colored.module.css"

    assert_forwarded to: "/vite-production/colored.module.css"
  end

  it "random_extension_css" do
    get_with_dev_server_running "/vite-production/colored.bubble.css"

    assert_forwarded to: "/vite-production/colored.bubble.css"
  end

  it "without_dev_server_running" do
    get "/vite-production/application.js"

    assert_not_forwarded

    get "/entrypoints/colored.css?import&t=1611322562923"

    assert_not_forwarded

    header "Referer", "http://localhost:3000/vite-production/application.js"
    get "/entrypoints/example_import.js"

    assert_not_forwarded
  end

  it "empty_public_output_dir" do
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
    expect(last_response).to be(:ok?)
    env = JSON.parse(last_response.body)

    expect(env["HTTP_X_FORWARDED_HOST"]).to be_nil
    expect(env["HTTP_X_FORWARDED_PORT"]).to be_nil
  end

  def assert_forwarded(to: nil)
    expect(last_response).to be(:ok?)
    env = JSON.parse(last_response.body)

    expect(env["HTTP_X_FORWARDED_HOST"]).to be == ViteRuby.config.host
    expect(Integer(env["HTTP_X_FORWARDED_PORT"])).to be == ViteRuby.config.port

    return unless to

    path, query = to.split("?")

    expect(env["PATH_INFO"]).to be == path
    expect(env["QUERY_STRING"].to_s).to be == query.to_s
    expect(env["REQUEST_URI"]).to be == to
  end
end
