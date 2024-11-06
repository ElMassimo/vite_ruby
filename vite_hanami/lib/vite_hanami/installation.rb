# frozen_string_literal: true

require "vite_hanami"

# Internal: Extends the base installation script from Vite Ruby to work for a
# typical Hanami app.
module ViteHanami::Installation
  HANAMI_TEMPLATES = Pathname.new(File.expand_path("../../templates", __dir__))

  # Override: Setup a typical apps/web Hanami app to use Vite.
  def setup_app_files
    cp HANAMI_TEMPLATES.join("config/hanami-vite.json"), config.config_path
    inject_line_after root.join("config/environment.rb"), "environment :development do", "    middleware.use(ViteRuby::DevServerProxy, ssl_verify_none: true) if ViteRuby.run_proxy?"
    inject_line_after_last root.join("apps/web/application.rb"), "include Web::Assets::Helpers", "        include ViteHanami::TagHelpers"
    inject_line_after root.join("apps/web/application.rb"), "configure :development do", <<-CSP
      # Allow @vite/client to hot reload changes in development
      security.content_security_policy(
        security.content_security_policy
          .sub('script-src', "script-src 'unsafe-eval' 'unsafe-inline'")
          .sub('connect-src', "connect-src ws://\#{ ViteRuby.config.host_with_port }")
          .sub('style-src', "style-src 'unsafe-inline'")
      )
    CSP
    append root.join("Rakefile"), <<~RAKE
      require 'vite_hanami'
      ViteRuby.install_tasks
    RAKE
  end

  # Override: Inject the vite client and sample script to the default HTML template.
  def install_sample_files
    super
    inject_line_before root.join("apps/web/templates/application.html.erb"), "</head>", <<-HTML
    <%= vite_client %>
    <%= vite_javascript 'application' %>
    HTML
  end
end

ViteRuby::CLI::Install.prepend(ViteHanami::Installation)
