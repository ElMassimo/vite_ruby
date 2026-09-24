# frozen_string_literal: true

# Public: Executes Vite commands, providing conveniences for debugging.
class ViteRuby::Runner
  # Internal: Marks the processes that the runner starts. It has no VITE_ prefix, so Vite does not expose it.
  RUNNER_PID_ENV_VAR = "RUBY_VITE_RUNNER_PID"

  # Internal: Stops a package manager from starting this gem's `vite` again. vite-plugin-ruby removes the marker.
  def self.check_for_self_invocation!
    return unless ENV[RUNNER_PID_ENV_VAR]

    package_manager = ViteRuby.config.package_manager
    runner = [*package_runner(package_manager), "vite"].join(" ")
    raise ViteRuby::MissingExecutableError, <<~MSG
      vite_ruby could not find the Vite executable, and `#{runner}` started vite_ruby's own `vite` command.
      Run `#{package_manager} install` and try again.
    MSG
  end

  # Internal: Returns the command that runs a package executable.
  def self.package_runner(package_manager)
    case package_manager
    when "npm" then %w[npx]
    when "pnpm" then %w[pnpm exec]
    when "bun" then %w[bun x --bun]
    when "yarn" then %w[yarn]
    else raise ArgumentError, "Unknown package manager #{package_manager.inspect}"
    end
  end

  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Executes Vite with the specified arguments.
  def run(argv, exec: false)
    config.within_root {
      cmd = command_for(argv)
      return Kernel.exec(*cmd) if exec

      log_or_noop = ->(line) { logger.info("vite") { line } } unless config.hide_build_console_output
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
    [config.to_env(env).merge(RUNNER_PID_ENV_VAR => Process.pid.to_s)].tap do |cmd|
      exec_args, vite_args = args.partition { |arg| arg.start_with?("--node-options") }
      cmd.push(*vite_executable(*exec_args))
      cmd.push(*vite_args)
      cmd.push("--mode", config.mode) unless args.include?("--mode") || args.include?("-m")
    end
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable(*exec_args)
    bin_path = config.vite_bin_path
    return [bin_path] if bin_path && File.exist?(bin_path)

    [*self.class.package_runner(config.package_manager), *exec_args, "vite"]
  end
end
