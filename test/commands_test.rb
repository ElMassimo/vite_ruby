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
      ensure_output_dirs(config)

      js_file = config.build_output_dir.join('assets/application.js')
      js_file.write('export {}')
      css_module = config.build_output_dir.join('assets/styles.css')
      css_module.write('.foo {}')
      image = config.build_output_dir.join('assets/image.svg')
      image.write('<svg/>')

      # Simulate using vite-plugin-rails & rollup-plugin-gzip to produce
      # source maps, gzip & brotli compressed versions of the file.
      source_map_file = config.build_output_dir.join('assets/application.js.map')
      source_map_file.write('export {}')
      gzip_file = config.build_output_dir.join('assets/application.js.gz')
      gzip_file.write('export {}')
      brotli_file = config.build_output_dir.join('assets/application.js.br')
      brotli_file.write('export {}')
      css_gzip_file = config.build_output_dir.join('assets/styles.css.gz')
      css_gzip_file.write('.foo {}')
      css_brotli_file = config.build_output_dir.join('assets/styles.css.br')
      css_brotli_file.write('.foo {}')

      # Should not clean, the manifest does not exist.
      refute clean

      manifest = config.build_output_dir.join('.vite/manifest.json')
      manifest.write('{}')

      # Should not clean, the file is recent.
      assert clean_from_task(OpenStruct.new)
      assert_path_exists manifest
      assert_path_exists js_file
      assert_path_exists source_map_file
      assert_path_exists gzip_file
      assert_path_exists brotli_file
      assert_path_exists css_module
      assert_path_exists css_gzip_file
      assert_path_exists css_brotli_file
      assert_path_exists image

      # Should not clean if directly referenced.
      manifest.write('{
        "application.js": {
          "assets": [
            "assets/image.svg"
          ],
          "css": [
            "assets/styles.css"
          ],
          "file": "assets/application.js"
        },
        "noassetsorcss.js": {
          "file": "assets/noassetsorcss.js"
        }
      }')
      assert clean(keep_up_to: 0, age_in_seconds: 0)
      assert_path_exists manifest
      assert_path_exists js_file
      assert_path_exists source_map_file
      assert_path_exists gzip_file
      assert_path_exists brotli_file
      assert_path_exists css_module
      assert_path_exists css_gzip_file
      assert_path_exists css_brotli_file
      assert_path_exists image

      # Should clean if we remove age restrictions.
      manifest.write('{}')
      assert clean(keep_up_to: 0, age_in_seconds: 0)
      assert_path_exists config.build_output_dir
      assert_path_exists manifest
      refute_path_exists js_file
      refute_path_exists source_map_file
      refute_path_exists gzip_file
      refute_path_exists brotli_file
      refute_path_exists css_module
      refute_path_exists css_gzip_file
      refute_path_exists css_brotli_file
      refute_path_exists image
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
