# frozen_string_literal: true

module ViteRuby::PackageManager
  class Bun < Base
    def install_dependencies_command(frozen: true)
      frozen ? 'bun install --frozen-lockfile' : 'bun install'
    end

    def add_dependencies_command
      'bun install'
    end

  private

    def nodejs_runtime?
      false
    end

    def vite_executable
      shimmed_vite_executable = super || ['vite']

      # Forces a script or package to use Bun's runtime instead of Node.js (via symlinking node)
      shimmed_vite_executable.unshift('bun', '--bun')
    end
  end
end
