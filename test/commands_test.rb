# frozen_string_literal: true

require "test_helper"

describe "Commands" do
  delegate :build, :build_from_task, :clobber, to: "ViteRuby.commands"

  def ensure_output_dirs(config)
    config.build_output_dir.rmtree rescue nil
    config.build_output_dir.mkdir unless config.build_output_dir.exist?
    config.build_output_dir.join(".vite").mkdir unless config.build_output_dir.join(".vite").exist?
    config.build_output_dir.join("assets").mkdir unless config.build_output_dir.join("assets").exist?
  end

  test "bootstrap" do
    assert(ViteRuby.bootstrap)
  end

  test "build returns success status when stale" do
    stub_builder(stale: true, build_successful: true) {
      assert(build)
      assert(build_from_task)
    }
  end

  test "build returns success status when fresh" do
    stub_builder(stale: false, build_successful: true) {
      assert(build)
      assert(build_from_task)
    }
  end

  test "build returns failure status when fresh" do
    stub_builder(stale: false, build_successful: false) {
      refute(build)
    }
  end

  test "build returns failure status when stale" do
    stub_builder(stale: true, build_successful: false) {
      refute(build)
    }
  end

  test "clobber" do
    with_rails_env("test") { |config|
      ensure_output_dirs(config)
      config.build_output_dir.join(".vite/manifest.json").write("{}")

      expect(config.build_output_dir).to_be(:exist?)
      clobber

      expect(config.build_output_dir).not_to_be(:exist?)
    }
  end
end
