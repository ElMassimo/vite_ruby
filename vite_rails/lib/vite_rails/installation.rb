# frozen_string_literal: true

# Internal: Extends the base installation script from Vite Ruby to work for a
# typical Rails app.
module ViteRails::Installation
  RAILS_TEMPLATES = Pathname.new(File.expand_path('../../../templates', __dir__))

  # Override: Setup a typical apps/web Hanami app to use Vite.
  def setup_app_files
    cp RAILS_TEMPLATES.join('config/rails-vite.json'), to: config.config_path
    setup_content_security_policy root.join('config/initializers/content_security_policy.rb')
  end

  # Internal: Configure CSP rules that allow to load @vite/client correctly.
  def setup_content_security_policy(csp_file)
    inject_line_after csp_file, 'policy.connect_src', <<-CSP
    # Allow @vite/client to hot reload changes in development
    policy.connect_src *policy.connect_src, "ws://\#{ ViteRuby.config.host_with_port }"
    CSP
    inject_line_after csp_file, 'policy.script_src', <<-CSP
    # Allow @vite/client to hot reload changes in development
    policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRails.config.host_with_port }"
    CSP
  end

  # Override: Create a sample JS file and attempt to inject it in an HTML template.
  def install_sample_files
    cp RAILS_TEMPLATES.join('entrypoints/application.js'), to: config.resolved_entrypoints_dir.join('application.js')
    inject_line_before root.join('apps/web/templates/application.html.erb'), '</head>', <<-HTML
    <%= vite_client %>
    <%= vite_javascript 'application' %>
    HTML
  end
end

ViteRuby::CLI::Install.prepend(ViteHanami::Installation)
