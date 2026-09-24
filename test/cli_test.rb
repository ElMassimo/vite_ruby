# frozen_string_literal: true

require "test_helper"

class CLITest < ViteRuby::Test
  def test_build_stops_when_started_by_runner
    built = clobbered = false
    with_env("RUBY_VITE_RUNNER_PID" => "123") {
      Dir.chdir(path_to_test_app) {
        ViteRuby::Commands.stub_any_instance(:clobber, -> { clobbered = true }) {
          ViteRuby::Commands.stub_any_instance(:build_from_task, ->(*) { built = true }) {
            assert_raises(ViteRuby::MissingExecutableError) { ViteRuby::CLI::Build.new.call(mode: "production", clobber: true) }
          }
        }
      }
    }

    refute clobbered
    refute built
  end

  def test_dev_stops_when_started_by_runner
    with_env("RUBY_VITE_RUNNER_PID" => "123") {
      Kernel.stub(:exec, ->(*) { flunk "started the dev server" }) {
        assert_raises(ViteRuby::MissingExecutableError) { ViteRuby::CLI::Dev.new.call(mode: "development") }
      }
    }
  end

  def test_version_runs_when_started_by_runner
    printed = false
    with_env("RUBY_VITE_RUNNER_PID" => "123") {
      ViteRuby::Commands.stub_any_instance(:print_info, -> { printed = true }) { ViteRuby::CLI::Version.new.call }
    }

    assert printed
  end
end
