# frozen_string_literal: true

# Internal: Extends the base installation script from Vite Ruby to work for a
# typical Rails app.
module ViteRails::Installation
  RAILS_TEMPLATES = Pathname.new(File.expand_path('../../templates', __dir__))

  # Override: Setup a typical apps/web Hanami app to use Vite.
  def setup_app_files
    cp RAILS_TEMPLATES.join('config/rails-vite.json'), config.config_path
    setup_content_security_policy root.join('config/initializers/content_security_policy.rb')
  end

  # Internal: Configure CSP rules that allow to load @vite/client correctly.
  def setup_content_security_policy(csp_file)
    inject_line_after csp_file, 'policy.script_src', <<-CSP
    # You may need to enable this in production as well depending on your setup.
    policy.script_src *policy.script_src, :blob if Rails.env.test?
    CSP
    inject_line_after csp_file, 'policy.connect_src', <<-CSP
    # Allow @vite/client to hot reload changes in development
    policy.connect_src *policy.connect_src, "ws://\#{ ViteRuby.config.host_with_port }" if Rails.env.development?
    CSP
    inject_line_after csp_file, 'policy.script_src', <<-CSP
    # Allow @vite/client to hot reload changes in development
    policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }" if Rails.env.development?
    CSP
  end

  # Override: Create a sample JS file and attempt to inject it in an HTML template.
  def install_sample_files
    cp RAILS_TEMPLATES.join('entrypoints/application.js'), config.resolved_entrypoints_dir.join('application.js')
    inject_line_before root.join('app/views/layouts/application.html.erb'), '</head>', <<-HTML
    <%= vite_client_tag %>
    <%= vite_javascript_tag 'application' %>
    HTML
  end
end

ViteRuby::CLI::Install.prepend(ViteRails::Installation)
