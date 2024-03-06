# frozen_string_literal: true

class ViteRuby::PackageManager::Base
  attr_reader :root

  def initialize(root: ViteRuby.config.root)
    @root = root
  end

  def install_dependencies_command(frozen: true)
    if frozen
      commands.legacy_npm_version? ? 'npm ci --yes' : 'npm --yes ci'
    end
  end

  def add_dependencies_command
    'npm install'
  end

  # Internal: Returns an Array with the command to run.
  def command_for(args)
    [config.to_env(env)].tap do |cmd|
      args = args.clone

      if nodejs_runtime? && (args.include?('--inspect') || args.include?('--trace_deprecation'))
        cmd.push('node')
        cmd.push('--inspect-brk') if args.delete('--inspect')
        cmd.push('--trace-deprecation') if args.delete('--trace_deprecation')
      end

      cmd.push(*vite_executable)
      cmd.push(*args)

      # force mode to be set
      cmd.push('--mode', config.mode) unless args.include?('--mode') || args.include?('-m')
    end
  end

  private

  def nodejs_runtime?
    true
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable
    bin_path = config.vite_bin_path
    [bin_path] if File.exist?(bin_path)
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
