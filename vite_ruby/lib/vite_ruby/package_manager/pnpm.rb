# frozen_string_literal: true

module ViteRuby::PackageManager
  class Pnpm < Npm
    def install_dependencies_command(frozen: true)
      frozen ? 'pnpm install --frozen-lockfile' : 'pnpm install'
    end

    def add_dependencies_command
      'pnpm install'
    end
  end
end
