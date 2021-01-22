# frozen_string_literal: true

# Public: Executes Vite commands, providing conveniences for debugging.
class ViteRails::Runner
  def initialize(argv)
    detect_unsupported_switches!(argv)
    @argv = argv
  end

  # Public: Executes Vite with the specified arguments.
  def run
    execute_command(@argv.clone)
  end

private

  UNSUPPORTED_SWITCHES = %w[--host --port --https --root -r --config -c]
  private_constant :UNSUPPORTED_SWITCHES

  # Internal: Allows to prevent configuration mistakes by ensuring the Rails app
  # and vite-plugin-ruby are using the same configuration for the dev server.
  def detect_unsupported_switches!(args)
    return unless (unsupported = UNSUPPORTED_SWITCHES & args).any?

    $stdout.puts "Please set the following switches in your vite.json instead: #{ unsupported }."
    exit!
  end

  # Internal: Executes the command with the specified arguments.
  def execute_command(args)
    cmd = vite_executable
    cmd.prepend('node', '--inspect-brk') if args.include?('--debug')
    cmd.prepend('node', '--trace-deprecation') if args.delete('--trace-deprecation')
    args.append('--mode', ENV['RAILS_ENV']) unless args.include?('--mode') || args.include?('-m')
    cmd += args
    Dir.chdir(File.expand_path('.', Dir.pwd)) { Kernel.exec(ViteRails.env, *cmd) }
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable
    executable_exists?(path = vite_bin_path) ? [path] : %w[yarn vite]
  end

  # Internal: Only so that we can easily cover both paths in tests
  def executable_exists?(path)
    File.exist?(path)
  end

  # Internal: Returns a path where a Vite executable should be found.
  def vite_bin_path
    ENV["#{ ViteRails::ENV_PREFIX }_VITE_BIN_PATH"] || `yarn bin vite`.chomp.presence || "#{ `npm bin`.chomp }/vite"
  end
end
