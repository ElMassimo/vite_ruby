# frozen_string_literal: true

class ViteRuby::CLI::UpgradePackages < ViteRuby::CLI::Install
  desc 'Upgrades the npm packages to the recommended versions.'

  def call(**)
    say 'Upgrading npm packages'
    deps = js_dependencies.join(' ')
    run_with_capture("#{ npm_install } -D #{ deps }")
  end
end
