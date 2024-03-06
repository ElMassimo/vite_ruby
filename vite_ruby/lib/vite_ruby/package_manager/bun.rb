# frozen_string_literal: true

module ViteRuby::PackageManager
  class Bun < Base
    attr_reader :root

    def initialize(root: ViteRuby.config.root)
      @root = root
    end

    def install_dependencies_command(frozen: true)
      frozen ? 'bun install --frozen-lockfile' : 'bun install'
    end

    def add_dependencies_command
      'bun install'
    end

    private

    def bun?
      true
    end

    def vite_executable
      shimmed_vite_executable = super || ['vite']

      # Forces a script or package to use Bun's runtime instead of Node.js (via symlinking node)
      shimmed_vite_executable.unshift('bun', '--bun')
    end
  end
end
