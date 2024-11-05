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
end
