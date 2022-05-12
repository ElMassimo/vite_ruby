# frozen_string_literal: true

class ViteRuby::CLI::SSR < ViteRuby::CLI::Vite
  DEFAULT_ENV = CURRENT_ENV || 'production'

  desc 'Run the resulting app from building in SSR mode.'
  executable_options

  def call(mode:, inspect: false, trace_deprecation: false)
    ViteRuby.env['VITE_RUBY_MODE'] = mode
    cmd = [
      'node',
      ('--inspect-brk' if inspect),
      ('--trace-deprecation' if trace_deprecation),
      ViteRuby.config.ssr_output_dir.join('ssr.js'),
    ]
    Kernel.exec(*cmd.compact.map(&:to_s))
  end
end
