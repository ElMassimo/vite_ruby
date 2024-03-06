# frozen_string_literal: true

module ViteRuby::PackageManager
  def self.resolve(root:)
    if root.join('bun.lockb').exist?
      ViteRuby::PackageManager::Bun.new(root: root)
    elsif root.join('yarn.lock').exist?
      ViteRuby::PackageManager::Yarn.new(root: root)
    else
      ViteRuby::PackageManager::Base.new(root: root)
    end
  end
end
