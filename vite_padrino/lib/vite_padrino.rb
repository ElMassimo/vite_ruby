# frozen_string_literal: true

require "vite_ruby"
require "vite_padrino/version"
require "vite_padrino/tag_helpers"

module VitePadrino
  # Internal: Called when the Rack app is available.
  def self.registered(app)
    if RACK_ENV != "production" && ViteRuby.run_proxy?
      app.use(ViteRuby::DevServerProxy, ssl_verify_none: true)
    end
    ViteRuby.instance.logger = app.logger
    included(app)
  end

  # Internal: Called when the module is registered in the Padrino app.
  def self.included(base)
    base.send :include, VitePadrino::TagHelpers
  end
end
