# frozen_string_literal: true

module ViteRuby::PackageManager
  class Yarn < Base
    attr_reader :root

    def initialize(root: ViteRuby.config.root)
      @root = root
    end

    def install_dependencies_command(frozen: true)
      frozen ? 'yarn install --frozen-lockfile' : 'yarn install'
    end

    def add_dependencies_command
      'yarn add'
    end

    private

    def yarn?
      true
    end

    def vite_executable
      super || %w[yarn vite]
    end
  end
end
