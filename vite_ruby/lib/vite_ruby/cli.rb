# frozen_string_literal: true

require 'dry/cli'

# Public: Command line interface that allows to install the library, and run
# simple commands.
class ViteRuby::CLI
  extend Dry::CLI::Registry

  register 'build', Build, aliases: ['b']
  register 'clobber', Clobber, aliases: %w[clean clear]
  register 'dev', Dev, aliases: %w[d serve]
  register 'install', Install
  register 'version', Version, aliases: ['v', '-v', '--version', 'info']
  register 'upgrade', Upgrade, aliases: ['update']
  register 'upgrade_packages', UpgradePackages, aliases: ['update_packages']
end
