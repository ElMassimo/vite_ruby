# frozen_string_literal: true

# Public: Executes Vite commands, providing conveniences for debugging.
class ViteRuby::Runner
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Executes Vite with the specified arguments.
  def run(argv, exec: false)
    pp "run: #{argv}"
    config.within_root {
      cmd = command_for(argv)
      return Kernel.exec(*cmd) if exec

      log_or_noop = ->(line) { logger.info('vite') { line } } unless config.hide_build_console_output
      ViteRuby::IO.capture(*cmd, chdir: config.root, with_output: log_or_noop)
    }
  rescue Errno::ENOENT => error
    raise ViteRuby::MissingExecutableError, error
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :logger, :env

  # Internal: Returns an Array with the command to run.
  def command_for(args)
    puts '-' * 100
    puts 'command_for'
    [config.to_env(env)].tap do |cmd|
      args = args.clone
      unless config.root.join('bun.lockb').exist?
        puts '-' * 100
        puts 'WARNING: NOT BUN.'
        cmd.push('node', '--inspect-brk') if args.delete('--inspect')
        cmd.push('node', '--trace-deprecation') if args.delete('--trace_deprecation')
      end
      cmd.push(*vite_executable)
      cmd.push(*args)
      cmd.push('--mode', config.mode) unless args.include?('--mode') || args.include?('-m')
    end
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable
    bin_path = config.vite_bin_path

    if File.exist?(bin_path)
      return ['bun', '--bun', bin_path] if config.root.join('bun.lockb').exist?

      return [bin_path]
    end

    if config.root.join('bun.lockb').exist?
      %w[bun --bun vite]
    elsif config.root.join('yarn.lock').exist?
      %w[yarn vite]
    else
      ["#{ `npm bin`.chomp }/vite"]
    end
  end
end
