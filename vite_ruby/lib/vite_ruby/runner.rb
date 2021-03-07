# frozen_string_literal: true

require 'open3'

# Public: Executes Vite commands, providing conveniences for debugging.
class ViteRuby::Runner
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Executes Vite with the specified arguments.
  def run(argv, capture: false)
    if capture
      capture3_with_output(*command_for(argv), chdir: config.root)
    else
      Dir.chdir(config.root) { Kernel.exec(*command_for(argv)) }
    end
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :logger

  # Internal: Returns an Array with the command to run.
  def command_for(args)
    [config.to_env].tap do |cmd|
      args = args.clone
      cmd.append('node', '--inspect-brk') if args.delete('--inspect')
      cmd.append('node', '--trace-deprecation') if args.delete('--trace_deprecation')
      cmd.append(*vite_executable(cmd))
      cmd.append(*args)
      cmd.append('--mode', config.mode) unless args.include?('--mode') || args.include?('-m')
    end
  end

  # Internal: Resolves to an executable for Vite.
  def vite_executable(cmd)
    cmd.include?('node') ? ['./node_modules/.bin/vite'] : ['npx', '--no-install', '--', 'vite']
  end

  # Internal: A modified version of capture3 that continuosly prints stdout.
  # NOTE: This improves the experience of running bin/vite build.
  def capture3_with_output(*cmd, **opts)
    return Open3.capture3(*cmd, opts) if config.hide_build_console_output

    Open3.popen3(*cmd, opts) { |_stdin, stdout, stderr, wait_threads|
      out = Thread.new { read_lines(stdout) { |l| logger.info('vite') { l } } }
      err = Thread.new { stderr.read }
      [out.value, err.value, wait_threads.value]
    }
  end

  # Internal: Reads and yield every line in the stream. Returns the full content.
  def read_lines(io)
    buffer = +''
    while line = io.gets
      buffer << line
      yield line
    end
    buffer
  end
end
