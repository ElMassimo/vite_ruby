# frozen_string_literal: true

require 'test_helper'

class CommandsTest < ViteRuby::Test
  def test_bootstrap
    assert ViteRuby.bootstrap
  end

  delegate :build, :build_from_task, :clobber, to: 'ViteRuby.commands'

  def test_build_returns_success_status_when_stale
    stub_builder(stale: true, build_successful: true) {
      assert build
      assert build_from_task
    }
  end

  def test_build_returns_success_status_when_fresh
    stub_builder(stale: false, build_successful: true) {
      assert build
      assert build_from_task
    }
  end

  def test_build_returns_failure_status_when_fresh
    stub_builder(stale: false, build_successful: false) {
      refute build
    }
  end

  def test_build_returns_failure_status_when_stale
    stub_builder(stale: true, build_successful: false) {
      refute build
    }
  end

  def test_clobber
    with_rails_env('test') { |config|
      ensure_output_dirs(config)
      config.build_output_dir.join('.vite/manifest.json').write('{}')
      assert_path_exists config.build_output_dir
      clobber
      refute_path_exists config.build_output_dir
    }
  end

private

  def ensure_output_dirs(config)
    config.build_output_dir.rmtree rescue nil
    config.build_output_dir.mkdir unless config.build_output_dir.exist?
    config.build_output_dir.join('.vite').mkdir unless config.build_output_dir.join('.vite').exist?
    config.build_output_dir.join('assets').mkdir unless config.build_output_dir.join('assets').exist?
  end
end
