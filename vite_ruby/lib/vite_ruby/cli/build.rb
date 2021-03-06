# frozen_string_literal: true

class ViteRuby::CLI::Build < Dry::CLI::Command
  CURRENT_ENV = ENV['RACK_ENV'] || ENV['RAILS_ENV']
  DEFAULT_ENV = CURRENT_ENV || 'production'

  def self.shared_options
    option(:mode, default: self::DEFAULT_ENV, values: %w[development production], aliases: ['m'], desc: 'The build mode for Vite')
  end

  desc 'Bundle all entrypoints using Vite.'
  shared_options

  def call(mode:, args: [])
    ViteRuby.env['VITE_RUBY_MODE'] = mode
    block_given? ? yield(mode) : ViteRuby.commands.build_from_task(*args)
  end
end
