# frozen_string_literal: true

namespace :vite do
  desc 'Verifies if Vite Rails is installed'
  task :verify_install do
    unless File.exist?(Rails.root.join('bin/vite'))
      warn <<~WARN
        vite binstub not found.
        Have you run rails vite:install?
        Make sure the bin directory and bin/vite are not included in .gitignore
      WARN
      exit!
    end
    config_path = Rails.root.join(ViteRails.config.config_path)
    unless config_path.exist?
      warn <<~WARN
        Configuration #{ config_path } file for vite-plugin-ruby not found.
        Make sure vite:install has run successfully before running dependent tasks.
      WARN
      exit!
    end
  end
end
