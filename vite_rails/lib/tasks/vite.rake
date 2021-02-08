# frozen_string_literal: true

load 'vite_ruby/tasks/vite.rake'

namespace :vite_rails do
  desc 'Fixes Rails management of node dev dependencies (build dependencies)'
  task :set_node_env do
    ENV['NODE_ENV'] = 'development'
  end
end

# Set NODE_ENV before installation, so that Rails installs JS build dependencies
# on servers that precompile assets.
['yarn:install', 'webpacker:yarn_install'].each do |name|
  Rake::Task[name].enhance([:'vite_rails:set_node_env']) if Rake::Task.task_defined?(name)
end
