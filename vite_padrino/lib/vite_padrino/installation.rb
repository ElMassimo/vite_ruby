# frozen_string_literal: true

require "vite_padrino"

# Internal: Extends the base installation script from Vite Ruby to work for a
# typical Padrino app.
module VitePadrino::Installation
  PADRINO_TEMPLATES = Pathname.new(File.expand_path("../../templates", __dir__))

  # Override: Setup a typical apps/web Padrino app to use Vite.
  def setup_app_files
    cp PADRINO_TEMPLATES.join("config/padrino-vite.json"), config.config_path
    inject_line_after root.join("app/app.rb"), "register", "    register VitePadrino"
    append root.join("Rakefile"), <<~RAKE
      require 'vite_padrino'
      ViteRuby.install_tasks
    RAKE
  end

  # Override: Inject the vite client and sample script to the default HTML template.
  def install_sample_files
    super
    inject_line_after root.join("app/views/layouts/application.haml"), "%title", <<-HTML
    = vite_client_tag
    = vite_javascript_tag 'application'
    HTML
  end
end

ViteRuby::CLI::Install.prepend(VitePadrino::Installation)
