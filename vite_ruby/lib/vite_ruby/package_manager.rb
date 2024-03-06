# frozen_string_literal: true

module ViteRuby::PackageManager
  def self.resolve(root:)
    if root.join('bun.lockb').exist?
      ViteRuby::PackageManager::Bun.new(root: root)
    elsif root.join('pnpm-lock.yaml').exist?
      ViteRuby::PackageManager::Pnpm.new(root: root)
    elsif root.join('yarn.lock').exist?
      ViteRuby::PackageManager::Yarn.new(root: root)
    else
      ViteRuby::PackageManager::Npm.new(root: root)
    end
  end
end
