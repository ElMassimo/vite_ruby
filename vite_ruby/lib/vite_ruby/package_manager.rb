# frozen_string_literal: true

module ViteRuby::PackageManager
  def self.resolve(root:)
    package_manager_name = ENV.fetch('VITE_RUBY_PACKAGE_MANAGER', detect_package_manager(root))
    package_manager_class_for(package_manager_name).new(root:)
  end

  private

  def self.package_manager_class_for(package_manager_name)
    case package_manager_name.to_sym
    when :bun
      ViteRuby::PackageManager::Bun
    when :pnpm
      ViteRuby::PackageManager::Pnpm
    when :yarn
      ViteRuby::PackageManager::Yarn
    else
      ViteRuby::PackageManager::Npm
    end
  end

  def self.detect_package_manager(root)
    if root.join('bun.lockb').exist?
      :bun
    elsif root.join('pnpm-lock.yaml').exist?
      :pnpm
    elsif root.join('yarn.lock').exist?
      :yarn
    else
      :npm
    end
  end
end

