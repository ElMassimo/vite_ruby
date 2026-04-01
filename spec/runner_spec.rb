# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ViteRuby::Runner" do
  it "dev_server_command" do
    assert_run_command(flags: ["--mode", "production"])
  end

  it "dev_server_command_with_argument" do
    assert_run_command("--quiet", flags: ["--mode", "production"])
  end

  it "build_command" do
    assert_run_command("build", flags: ["--mode", "production"])
  end

  it "build_command_with_argument" do
    with_rails_env("development") do
      assert_run_command("build", "--emptyOutDir", flags: ["--mode", "development"])
    end
  end

  it "command_capture" do
    allow_any_instance_of(ViteRuby::Runner).to receive(:vite_executable).and_return(["echo"])
    stdout, stderr, status = ViteRuby.run(['"Hello"'])

    expect(stdout).to eq(%("Hello" --mode production\n))
    expect(stderr).to eq("")
    expect(status).to be_truthy
  end
end
