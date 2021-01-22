# frozen_string_literal: true

require 'rack/proxy'

# Public: Allows to relay asset requests to the Vite development server.
class ViteRails::DevServerProxy < Rack::Proxy
  VITE_DEPENDENCY_PREFIX = '/@'

  def initialize(app = nil, options = {})
    @vite_rails = options.delete(:vite_rails) || ViteRails.instance
    options[:streaming] = false if Rails.env.test? && !options.key?(:streaming)
    super
  end

  # Rack: Intercept asset requests and send them to the Vite server.
  def perform_request(env)
    if vite_should_handle?(env['REQUEST_URI'], env['HTTP_REFERER']) && dev_server.running?
      rewrite_request_uri(env)
      env['HTTP_HOST'] = env['HTTP_X_FORWARDED_HOST'] = config.host
      env['HTTP_X_FORWARDED_SERVER'] = config.host_with_port
      env['HTTP_PORT'] = env['HTTP_X_FORWARDED_PORT'] = config.port.to_s
      env['HTTP_X_FORWARDED_PROTO'] = env['HTTP_X_FORWARDED_SCHEME'] = config.protocol
      env['HTTPS'] = env['HTTP_X_FORWARDED_SSL'] = 'off' unless config.https
      env['SCRIPT_NAME'] = ''
      super(env)
    else
      @app.call(env)
    end
  end

private

  delegate :config, :dev_server, to: :@vite_rails

  def rewrite_request_uri(env)
    env['REQUEST_URI'] = env['REQUEST_URI']
      .sub(vite_asset_url_prefix, '/')
      .sub('.ts.js', '.ts') # Patch: Rails helpers always append the extension.
    env['PATH_INFO'], env['QUERY_STRING'] = env['REQUEST_URI'].split('?')
  end

  def vite_should_handle?(url, referer)
    return true if url.start_with?(vite_asset_url_prefix) # Vite Asset
    return true if url.start_with?(VITE_DEPENDENCY_PREFIX) # Vite Package Asset
    return true if url.include?('?t=') # Hot Reload
    return true if referer && URI.parse(referer).path.start_with?(vite_asset_url_prefix) # Entry Imported from another Entry.
  end

  def vite_asset_url_prefix
    @vite_asset_url_prefix ||= "/#{ config.public_output_dir }/"
  end
end
