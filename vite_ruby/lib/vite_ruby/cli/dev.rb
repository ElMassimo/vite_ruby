# frozen_string_literal: true

class ViteRuby::CLI::Dev < ViteRuby::CLI::Build
  DEFAULT_ENV = CURRENT_ENV || 'development'

  desc 'Start the Vite development server.'
  shared_options

  def call(mode:, args: [])
    super(mode: mode) { ViteRuby.run(args) }
  end
end
