# frozen_string_literal: true

require "test_helper"

describe "CommandsTest" do
  include ViteRubyTestHelpers

  it "bootstrap" do
    expect(ViteRuby.bootstrap).to be_truthy
  end

  it "build returns success status when stale" do
    stub_builder(stale: true, build_successful: true) {
      expect(build).to be_truthy
      expect(build_from_task).to be_truthy
    }
  end

  it "build returns success status when fresh" do
    stub_builder(stale: false, build_successful: true) {
      expect(build).to be_truthy
      expect(build_from_task).to be_truthy
    }
  end

  it "build returns failure status when fresh" do
    stub_builder(stale: false, build_successful: false) {
      expect(build).to be_falsey
    }
  end

  it "build returns failure status when stale" do
    stub_builder(stale: true, build_successful: false) {
      expect(build).to be_falsey
    }
  end

  it "clobber" do
    with_rails_env("test") { |config|
      ensure_output_dirs(config)
      config.build_output_dir.join(".vite/manifest.json").write("{}")

      expect(config.build_output_dir).to be(:exist?)
      clobber

      expect(config.build_output_dir).not.to be(:exist?)
    }
  end

private

  def build
    ViteRuby.commands.build
  end

  def build_from_task
    ViteRuby.commands.build_from_task
  end

  def clobber
    ViteRuby.commands.clobber
  end

  def ensure_output_dirs(config)
    config.build_output_dir.rmtree rescue nil
    config.build_output_dir.mkdir unless config.build_output_dir.exist?
    config.build_output_dir.join(".vite").mkdir unless config.build_output_dir.join(".vite").exist?
    config.build_output_dir.join("assets").mkdir unless config.build_output_dir.join("assets").exist?
  end
end
