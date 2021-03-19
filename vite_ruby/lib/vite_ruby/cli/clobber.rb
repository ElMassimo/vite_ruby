# frozen_string_literal: true

class ViteRuby::CLI::Clobber < Dry::CLI::Command
  desc 'Clear the Vite cache, temp files, and builds'

  def call(**)
    ViteRuby.commands.clobber
  end
end
