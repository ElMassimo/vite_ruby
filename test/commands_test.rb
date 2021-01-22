# frozen_string_literal: true

require 'test_helper'

class CommandsTest < ViteRails::Test
  def stub_builder(stale:, build_with_vite:)
    ViteRails.builder.stub :stale?, stale do
      ViteRails.builder.stub :build_with_vite, build_with_vite do
        yield
      end
    end
  end

  def test_bootstrap
    assert ViteRails.bootstrap
  end

  def test_build_returns_success_status_when_stale
    stub_builder(stale: true, build_with_vite: true) {
      assert_equal true, ViteRails.build
      assert_equal true, ViteRails.build_from_rake
    }
  end

  def test_build_returns_success_status_when_fresh
    stub_builder(stale: false, build_with_vite: true) {
      assert_equal true, ViteRails.build
      assert_equal true, ViteRails.build_from_rake
    }
  end

  def test_build_returns_failure_status_when_stale
    stub_builder(stale: true, build_with_vite: false) {
      assert_equal false, ViteRails.build
    }
  end

  def test_clean
    with_rails_env('test') { |config|
      manifest = config.build_output_dir.join('manifest.json')

      # Should not clean, the manifest does not exist.
      config.build_output_dir.mkdir unless config.build_output_dir.exist?
      refute ViteRails.clean

      # Should not clean, the file is recent.
      manifest.write('{}')
      assert ViteRails.clean_from_rake(OpenStruct.new)
      assert manifest.exist?

      # Should clean if we remove age restrictions.
      assert ViteRails.clean(keep_up_to: 0, age_in_seconds: 0)
      assert config.build_output_dir.exist?
      refute manifest.exist?
    }
  end

  def test_clobber
    with_rails_env('test') { |config|
      config.build_output_dir.mkdir unless config.build_output_dir.exist?
      config.build_output_dir.join('manifest.json').write('{}')
      assert config.build_output_dir.exist?
      ViteRails.clobber
      refute config.build_output_dir.exist?
    }
  end
end
