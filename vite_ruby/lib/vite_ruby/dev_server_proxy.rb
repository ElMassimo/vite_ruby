# frozen_string_literal: true

require 'rack/proxy'

# Public: Allows to relay asset requests to the Vite development server.
class ViteRuby::DevServerProxy < Rack::Proxy
  HOST_WITH_PORT_REGEX = %r{^(.+?)(:\d+)/}
  VITE_DEPENDENCY_PREFIX = '/@'

  def initialize(app = nil, options = {})
    @vite_ruby = options.delete(:vite_ruby) || ViteRuby.instance
    options[:streaming] = false if config.mode == 'test' && !options.key?(:streaming)
    super
  end

  # Rack: Intercept asset requests and send them to the Vite server.
  def perform_request(env)
    if vite_should_handle?(env) && dev_server_running?
      forward_to_vite_dev_server(env)
      super(env)
    else
      @app.call(env)
    end
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :dev_server_running?

  def rewrite_uri_for_vite(env)
    uri = env.fetch('REQUEST_URI') { [env['PATH_INFO'], env['QUERY_STRING']].reject { |str| str.to_s.strip.empty? }.join('?') }
      .sub(vite_asset_url_prefix, '/')
      .sub(HOST_WITH_PORT_REGEX, '/') # Hanami adds the host and port.
      .sub('.ts.js', '.ts') # Hanami's javascript helper always adds the extension.
      .sub(/(\.\w+)\.css$/, '\1') # Rails' stylesheet_link_tag always adds the extension.
    env['PATH_INFO'], env['QUERY_STRING'] = (env['REQUEST_URI'] = uri).split('?')
  end

  def forward_to_vite_dev_server(env)
    rewrite_uri_for_vite(env)
    env['QUERY_STRING'] ||= ''
    env['HTTP_HOST'] = env['HTTP_X_FORWARDED_HOST'] = config.host
    env['HTTP_X_FORWARDED_SERVER'] = config.host_with_port
    env['HTTP_PORT'] = env['HTTP_X_FORWARDED_PORT'] = config.port.to_s
    env['HTTP_X_FORWARDED_PROTO'] = env['HTTP_X_FORWARDED_SCHEME'] = config.protocol
    env['HTTPS'] = env['HTTP_X_FORWARDED_SSL'] = 'off' unless config.https
    env['SCRIPT_NAME'] = ''
  end

  def vite_should_handle?(env)
    path, query, referer = env['PATH_INFO'], env['QUERY_STRING'], env['HTTP_REFERER']
    return true if path.start_with?(vite_asset_url_prefix) # Vite asset
    return true if path.start_with?(VITE_DEPENDENCY_PREFIX) # Packages and imports
    return true if query&.start_with?('t=') # Hot Reload for a stylesheet
    return true if query&.start_with?('import&') # Hot Reload for an imported entrypoint
    return true if referer && URI.parse(referer).path.start_with?(vite_asset_url_prefix) # Entry imported from another entry.
  end

  def vite_asset_url_prefix
    @vite_asset_url_prefix ||= "/#{ config.public_output_dir }/"
  end
end
