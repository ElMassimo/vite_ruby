# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ViteRuby::Commands" do
  delegate :build, :build_from_task, :clobber, to: "ViteRuby.commands"

  it "bootstrap" do
    expect(ViteRuby.bootstrap).to be_truthy
  end

  it "build_returns_success_status_when_stale" do
    stub_builder(stale: true, build_successful: true) {
      expect(build).to be_truthy
      expect(build_from_task).to be_truthy
    }
  end

  it "build_returns_success_status_when_fresh" do
    stub_builder(stale: false, build_successful: true) {
      expect(build).to be_truthy
      expect(build_from_task).to be_truthy
    }
  end

  it "build_returns_failure_status_when_fresh" do
    stub_builder(stale: false, build_successful: false) {
      expect(build).to be_falsy
    }
  end

  it "build_returns_failure_status_when_stale" do
    stub_builder(stale: true, build_successful: false) {
      expect(build).to be_falsy
    }
  end

  it "clobber" do
    with_rails_env("test") { |config|
      ensure_output_dirs(config)
      config.build_output_dir.join(".vite/manifest.json").write("{}")

      expect(config.build_output_dir).to exist
      clobber

      expect(config.build_output_dir).not_to exist
    }
  end

private

  def ensure_output_dirs(config)
    config.build_output_dir.rmtree rescue nil
    config.build_output_dir.mkdir unless config.build_output_dir.exist?
    config.build_output_dir.join(".vite").mkdir unless config.build_output_dir.join(".vite").exist?
    config.build_output_dir.join("assets").mkdir unless config.build_output_dir.join("assets").exist?
  end
end
