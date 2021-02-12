# frozen_string_literal: true

# Set NODE_ENV before installation, so that Rails installs JS build dependencies
# on servers that precompile assets.
installation_tasks = ['yarn:install', 'webpacker:yarn_install'].select { |name| Rake::Task.task_defined?(name) }.each do |name|
  Rake::Task[name].enhance([:'vite_rails:set_node_env'])
end

# Ensure dependencies are installed in older versions of Rails
Rake::Task['assets:precompile']&.enhance([:'vite:install_dependencies']) if installation_tasks.none?

require 'vite_ruby'
ViteRuby.install_tasks

namespace :vite_rails do
  desc 'Fixes Rails management of node dev dependencies (build dependencies)'
  task :set_node_env do
    ENV['NODE_ENV'] = 'development'
  end
end
