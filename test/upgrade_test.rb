# frozen_string_literal: true

require "test_helper"

class UpgradeTest < ViteRuby::Test
  def test_updates_gems_conservatively
    libraries = [
      ["rails", Struct.new(:name).new("vite_rails")],
      ["rack", Struct.new(:name).new("vite_plugin_legacy")],
    ]
    status = MockProcessStatus.new

    ViteRuby.stub(:framework_libraries, libraries) do
      ViteRuby::IO.stub(:capture, ->(*command) {
        assert_equal ["bundle update --conservative vite_ruby vite_rails vite_plugin_legacy"], command
        ["", "", status]
      }) do
        ViteRuby::CLI::Upgrade.new.send(:upgrade_ruby_gems)
      end
    end
  end
end
