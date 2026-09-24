# frozen_string_literal: true

require "test_helper"

class RunnerTest < ViteRuby::Test
  def test_dev_server_command
    assert_run_command(flags: ["--mode", "production"])
  end

  def test_dev_server_command_with_argument
    assert_run_command("--quiet", flags: ["--mode", "production"])
  end

  def test_build_command
    assert_run_command("build", flags: ["--mode", "production"])
  end

  def test_build_command_with_argument
    with_rails_env("development") do
      assert_run_command("build", "--emptyOutDir", flags: ["--mode", "development"])
    end
  end

  def test_command_capture
    ViteRuby::Runner.stub_any_instance(:vite_executable, "echo") {
      stdout, stderr, status = ViteRuby.run(['"Hello"'])

      assert_equal %("Hello" --mode production\n), stdout
      assert_equal "", stderr
      assert status
    }
  end

  def test_self_invocation_check_raises_when_started_by_runner
    refresh_config(package_manager: "bun")
    with_env("RUBY_VITE_RUNNER_PID" => "123") {
      ViteRuby::IO.stub(:capture, ->(*) { flunk "started a process" }) {
        error = assert_raises(ViteRuby::MissingExecutableError) {
          ViteRuby::Runner.check_for_self_invocation!
        }

        assert_includes error.message, "`bun x --bun vite` started vite_ruby's own `vite` command"
        assert_includes error.message, "Run `bun install` and try again."
      }
    }
  end

  def test_self_invocation_check_passes_when_not_started_by_runner
    with_env("RUBY_VITE_RUNNER_PID" => nil) {
      assert_nil ViteRuby::Runner.check_for_self_invocation!
    }
  end

  def test_command_adds_runner_marker_to_env
    assert_equal Process.pid.to_s, run_command("build").first["RUBY_VITE_RUNNER_PID"]
  end

private

  def run_command(*argv)
    Dir.chdir(path_to_test_app) {
      command = nil
      Kernel.stub(:exec, ->(*args) { command = args }) { ViteRuby.run(argv, exec: true) }
      command
    }
  end
end
