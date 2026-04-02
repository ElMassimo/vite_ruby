# frozen_string_literal: true

require "test_helper"

describe "RunnerTest" do
  include ViteRubyTestHelpers

  it "dev server command" do
    assert_run_command(flags: ["--mode", "production"])
  end

  it "dev server command with argument" do
    assert_run_command("--quiet", flags: ["--mode", "production"])
  end

  it "build command" do
    assert_run_command("build", flags: ["--mode", "production"])
  end

  it "build command with argument" do
    with_rails_env("development") do
      assert_run_command("build", "--emptyOutDir", flags: ["--mode", "development"])
    end
  end

  it "command capture" do
    original = ViteRuby::Runner.instance_method(:vite_executable)
    ViteRuby::Runner.define_method(:vite_executable) { "echo" }
    stdout, stderr, status = ViteRuby.run(['"Hello"'])
    ViteRuby::Runner.define_method(:vite_executable, original)

    expect(stdout).to be == %("Hello" --mode production\n)
    expect(stderr).to be == ""
    expect(status).to be_truthy
  end
end
