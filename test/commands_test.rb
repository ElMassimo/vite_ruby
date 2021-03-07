# frozen_string_literal: true

require 'test_helper'

class CommandsTest < ViteRuby::Test
  def test_bootstrap
    assert ViteRuby.bootstrap
  end

  delegate :build, :build_from_task, :clean, :clean_from_task, :clobber, to: 'ViteRuby.commands'

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

  def test_clean
    with_rails_env('test') { |config|
      manifest = config.build_output_dir.join('manifest.json')

      # Should not clean, the manifest does not exist.
      config.build_output_dir.mkdir unless config.build_output_dir.exist?
      refute clean

      # Should not clean, the file is recent.
      manifest.write('{}')
      assert clean_from_task(OpenStruct.new)
      assert_path_exists manifest

      # Should clean if we remove age restrictions.
      assert clean(keep_up_to: 0, age_in_seconds: 0)
      assert_path_exists config.build_output_dir
      refute_path_exists manifest
    }
  end

  def test_clobber
    with_rails_env('test') { |config|
      config.build_output_dir.mkdir unless config.build_output_dir.exist?
      config.build_output_dir.join('manifest.json').write('{}')
      assert_path_exists config.build_output_dir
      clobber
      refute_path_exists config.build_output_dir
    }
  end
end
