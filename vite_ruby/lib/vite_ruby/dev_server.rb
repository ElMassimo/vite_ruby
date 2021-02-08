# frozen_string_literal: true

# Public: Allows to verify if a Vite development server is already running.
class ViteRuby::DevServer
  extend Forwardable

  def_delegators :@config, :host, :port

  # Public: Vite dev server connection timeout (in seconds).
  CONNECT_TIMEOUT = 0.01

  def initialize(config)
    @config = config
  end

  # Public: Returns true if the Vite development server is reachable.
  def running?
    Socket.tcp(host, port, connect_timeout: CONNECT_TIMEOUT).close
    true
  rescue StandardError
    false
  end
end
