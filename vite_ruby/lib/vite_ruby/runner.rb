# frozen_string_literal: true

# Public: Executes Vite commands, providing conveniences for debugging.
class ViteRuby::Runner
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Executes Vite with the specified arguments.
  def run(argv, exec: false)
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
    @vite_ruby.package_manager.command_for(args)
  end
end
