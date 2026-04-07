# frozen_string_literal: true

require "test_helper"

describe "Runner" do
  test "dev server command" do
    assert_run_command(flags: ["--mode", "production"])
  end

  test "dev server command with argument" do
    assert_run_command("--quiet", flags: ["--mode", "production"])
  end

  test "build command" do
    assert_run_command("build", flags: ["--mode", "production"])
  end

  test "build command with argument" do
    with_rails_env("development") do
      assert_run_command("build", "--emptyOutDir", flags: ["--mode", "development"])
    end
  end

  test "command capture" do
    original = ViteRuby::Runner.instance_method(:vite_executable)
    ViteRuby::Runner.define_method(:vite_executable) { "echo" }
    stdout, stderr, status = ViteRuby.run(['"Hello"'])
    ViteRuby::Runner.define_method(:vite_executable, original)

    expect(stdout) == %("Hello" --mode production\n)
    expect(stderr) == ""
    assert(status)
  end
end
