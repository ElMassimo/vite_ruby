# frozen_string_literal: true

# Public: Allows to verify if a Vite development server is already running.
class ViteRails::DevServer
  # Public: Configure dev server connection timeout (in seconds).
  # Example:
  #   ViteRails.dev_server.connect_timeout = 1
  cattr_accessor(:connect_timeout) { 0.01 }

  def initialize(config)
    @config = config
  end

  # Public: Returns true if the Vite development server is reachable.
  def running?
    Socket.tcp(host, port, connect_timeout: connect_timeout).close
    true
  rescue StandardError
    false
  end

  delegate :host, :port, to: :@config
end
