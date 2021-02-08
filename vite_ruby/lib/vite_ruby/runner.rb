# frozen_string_literal: true

require 'open3'

# Public: Executes Vite commands, providing conveniences for debugging.
class ViteRuby::Runner
  # Public: Executes Vite with the specified arguments.
  def run(argv, **options)
    detect_unsupported_switches!(argv)
    execute_command(argv.clone, **options)
  end

private

  UNSUPPORTED_SWITCHES = %w[--host --port --https --root -r --config -c]
  private_constant :UNSUPPORTED_SWITCHES

  # Internal: Allows to prevent configuration mistakes by ensuring the Ruby app
  # and vite-plugin-ruby are using the same configuration for the dev server.
  def detect_unsupported_switches!(args)
    return unless (unsupported = UNSUPPORTED_SWITCHES & args).any?

    $stdout.puts "Please set the following switches in your vite.json instead: #{ unsupported }."
    exit!
  end

  # Internal: Executes the command with the specified arguments.
  def execute_command(args, capture: false)
    cmd = vite_executable
    cmd.prepend('node', '--inspect-brk') if args.include?('--debug')
    cmd.prepend('node', '--trace-deprecation') if args.delete('--trace-deprecation')
    args.append('--mode', ViteRuby.mode) unless args.include?('--mode') || args.include?('-m')
    cmd += args
    if capture
      Open3.capture3(vite_env, cmd.join(' '), chdir: ViteRuby.config.root)
    else
      Dir.chdir(ViteRuby.config.root) { Kernel.exec(vite_env, *cmd) }
    end
  end

  # Internal: The environment variables to pass to the command.
  def vite_env
    ViteRuby.config.to_env
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable
    %w[npx vite]
  end
end
