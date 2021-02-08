# frozen_string_literal: true

class ViteRuby::CLI::Build < Dry::CLI::Command
  def self.shared_options
    option(:mode, default: 'development', values: %w[development production], aliases: ['m'], desc: 'The build mode for Vite.')
  end

  desc 'Bundle all entrypoints using Vite.'
  shared_options

  def call(mode:)
    ViteRuby.env['VITE_RUBY_MODE'] = mode
    block_given? ? yield(mode) : ViteRuby.commands.build_from_task
  end
end
