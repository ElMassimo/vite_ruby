# frozen_string_literal: true

module ViteRuby::PackageManager
  class Npm < Base
    def install_dependencies_command(frozen: true)
      if frozen
        commands.legacy_npm_version? ? 'npm ci --yes' : 'npm --yes ci'
      else
        'npm install'
      end
    end

    def add_dependencies_command
      'npm install'
    end

  private

    # Internal: Resolves to an executable for Vite.
    def vite_executable
      super || ["#{ `npm bin`.chomp }/vite"]
    end
  end
end
