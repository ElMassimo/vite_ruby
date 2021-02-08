# frozen_string_literal: true

namespace :vite do
  desc 'Install all JavaScript dependencies as specified via Yarn'
  task :install_dependencies do
    valid_node_envs = %w[test development production]
    node_env = ENV.fetch('NODE_ENV') { valid_node_envs.include?(Rails.env) ? Rails.env : 'production' }
    Dir.chdir(Rails.root) do
      v1 = `yarn --version`.start_with?('1')
      install_command = "yarn install #{ v1 ? '--no-progress --frozen-lockfile' : '--immutable' } --production=false"
      system({ 'NODE_ENV' => node_env }, install_command)
    end
  end
end
