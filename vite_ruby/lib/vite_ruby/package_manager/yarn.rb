# frozen_string_literal: true

module ViteRuby::PackageManager
  class Yarn < Base
    def install_dependencies_command(frozen: true)
      frozen ? 'yarn install --frozen-lockfile' : 'yarn install'
    end

    def add_dependencies_command
      'yarn add'
    end

  private

    def vite_executable
      super || %w[yarn vite]
    end
  end
end
