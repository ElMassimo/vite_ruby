# frozen_string_literal: true

require 'open3'

# Public: Executes Vite commands, providing conveniences for debugging.
class ViteRuby::Runner
  # Public: Executes Vite with the specified arguments.
  def run(argv, **options)
    $stdout.sync = true
    detect_unsupported_switches!(argv)
    execute_command(argv.clone, **options)
  end

private

  UNSUPPORTED_SWITCHES = %w[--host --port --https --root -r --config -c].freeze

  # Internal: Allows to prevent configuration mistakes by ensuring the Ruby app
  # and vite-plugin-ruby are using the same configuration for the dev server.
  def detect_unsupported_switches!(args)
    return unless (unsupported = UNSUPPORTED_SWITCHES & args).any?

    $stdout.puts "Please set the following switches in your vite.json instead: #{ unsupported }."
    exit!
  end

  # Internal: Executes the command with the specified arguments.
  def execute_command(args, capture: false)
    if capture
      Open3.capture3(*command_for(args), chdir: ViteRuby.config.root)
    else
      Dir.chdir(ViteRuby.config.root) { Kernel.exec(*command_for(args)) }
    end
  end

  # Internal: Returns an Array with the command to run.
  def command_for(args)
    [vite_env].tap do |cmd|
      cmd.append('node', '--inspect-brk') if args.include?('--debug')
      cmd.append('node', '--trace-deprecation') if args.delete('--trace-deprecation')
      cmd.append(*vite_executable(cmd))
      cmd.append(*args)
      cmd.append('--mode', ViteRuby.mode) unless args.include?('--mode') || args.include?('-m')
    end
  end

  # Internal: The environment variables to pass to the command.
  def vite_env
    ViteRuby.config.to_env
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable(cmd)
    npx = cmd.include?('node') ? `which npx`.chomp("\n") : 'npx' rescue 'npx'
    [npx, 'vite']
  end
end
