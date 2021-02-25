# frozen_string_literal: true

Padrino.configure_apps do
  # enable :sessions
  set :session_secret, '592d4263c8634b39fc482553b4b60db29c9de5eb46e730eff33856599c41e480'
  set :protection, except: :path_traversal
  set :protect_from_csrf, true
end

# Mounts the core application for this project
Padrino.mount('BlogTutorial::App', app_file: Padrino.root('app/app.rb')).to('/')
