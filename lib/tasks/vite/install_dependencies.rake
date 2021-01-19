# frozen_string_literal: true

namespace :vite do
  desc 'Support for older Rails versions. Install all JavaScript dependencies as specified via Yarn'
  task :install_dependencies do
    valid_node_envs = %w[test development production]
    node_env = ENV.fetch('NODE_ENV') { valid_node_envs.include?(Rails.env) ? Rails.env : 'production' }
    Dir.chdir(Rails.root) do
      install_command = if Rails.root.join('yarn.lock').exist?
        v1 = `yarn --version`.start_with?('1')
        "yarn install #{ v1 ? '--no-progress --frozen-lockfile' : '--immutable' }"
      elsif Rails.root.join('pnpm-lock.yaml').exist?
        'pnpm install'
      else
        'npm ci'
      end
      system({ 'NODE_ENV' => node_env }, install_command)
    end
  end
end
