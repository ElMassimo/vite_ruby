# frozen_string_literal: true

require "vite_rails_legacy"

# Internal: Extends the base installation script from Vite Ruby to work for a
# typical Rails app.
module ViteRailsLegacy::Installation
  RAILS_TEMPLATES = Pathname.new(File.expand_path("../../templates", __dir__))

  # Override: Setup a typical apps/web Hanami app to use Vite.
  def setup_app_files
    cp RAILS_TEMPLATES.join("config/rails-vite.json"), config.config_path
    if root.join("app/javascript").exist?
      replace_first_line config.config_path, "app/frontend", %(    "sourceCodeDir": "app/javascript",)
    end
  end

  # Override: Create a sample JS file and attempt to inject it in an HTML template.
  def install_sample_files
    unless config.resolved_entrypoints_dir.join("application.js").exist?
      cp RAILS_TEMPLATES.join("entrypoints/application.js"), config.resolved_entrypoints_dir.join("application.js")
    end

    if (layout_file = root.join("app/views/layouts/application.html.erb")).exist?
      inject_line_before layout_file, "</head>", <<-HTML
    <%= vite_client_tag %>
    <%= vite_javascript_tag 'application' %>
    <!--
      If using a TypeScript entrypoint file:
        vite_typescript_tag 'application'

      If using a .jsx or .tsx entrypoint, add the extension:
        vite_javascript_tag 'application.jsx'

      Visit the guide for more information: https://vite-ruby.netlify.app/guide/rails
    -->
      HTML
    end
  end
end

ViteRuby::CLI::Install.prepend(ViteRailsLegacy::Installation)
