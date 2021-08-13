# frozen_string_literal: true

class ViteRuby::CLI::UpgradePackages < ViteRuby::CLI::Install
  desc 'Upgrades the npm packages to the recommended versions.'

  def call(**)
    say 'Upgrading npm packages'

    Dir.chdir(root) do
      deps = js_dependencies.join(' ')
      run_with_capture("npx --package @antfu/ni -- ni -D #{ deps }")
    end
  end
end
