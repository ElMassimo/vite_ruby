# frozen_string_literal: true

class ViteRuby::PackageManager::Yarn
  attr_reader :root

  def initialize(root: ViteRuby.config.root)
    @root = root
  end

  def install_dependencies_command(frozen: true)
    return frozen ? 'bun install --frozen-lockfile' : 'bun install' if bun?
    return frozen ? 'yarn install --frozen-lockfile' : 'yarn install' if yarn?
    return frozen ? 'pnpm install --frozen-lockfile' : 'pnpm install' if pnpm?

    if frozen
      commands.legacy_npm_version? ? 'npm ci --yes' : 'npm --yes ci'
    else
      'npm install'
    end
  end

  def add_dependencies_command
    return 'bun install' if bun?
    return 'yarn add' if yarn?
    return 'pnpm install' if pnpm?

    'npm install'
  end

  # Internal: Returns an Array with the command to run.
  def command_for(args)
    [config.to_env(env)].tap do |cmd|
      args = args.clone
      unless config.root.join('bun.lockb').exist?
        cmd.push('node', '--inspect-brk') if args.delete('--inspect')
        cmd.push('node', '--trace-deprecation') if args.delete('--trace_deprecation')
      end
      cmd.push(*vite_executable)
      cmd.push(*args)
      cmd.push('--mode', config.mode) unless args.include?('--mode') || args.include?('-m')
    end
  end

  private

  def pnpm?
    root.join('pnpm-lock.yaml').exist?
  end

  def bun?
    root.join('bun.lockb').exist?
  end

  def yarn?
    root.join('yarn.lock').exist?
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable
    bin_path = config.vite_bin_path

    if File.exist?(bin_path)
      # Forces a script or package to use Bun's runtime instead of Node.js (via symlinking node)
      return ['bun', '--bun', bin_path] if bun?

      return [bin_path]
    end

    if bun?
      %w[bun --bun vite]
    elsif yarn?
      %w[yarn vite]
    else
      ["#{ `npm bin`.chomp }/vite"]
    end
  end

  def commands
    ViteRuby.commands
  end

  def config
    ViteRuby.config
  end

  def env
    ViteRuby.env
  end
end
