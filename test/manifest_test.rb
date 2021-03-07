# frozen_string_literal: true

require 'test_helper'

class ManifestTest < ViteRuby::Test
  def setup
    super
    ViteRuby::Manifest.instance_eval { public :lookup, :lookup! }
  end

  def teardown
    ViteRuby::Manifest.instance_eval { private :lookup, :lookup! }
    super
  end

  delegate :path_for, :lookup, :lookup!, to: 'ViteRuby.instance.manifest'

  def test_lookup_exception!
    asset_file = 'calendar.js'

    error = assert_raises_manifest_missing_entry_error do
      path_for(asset_file)
    end

    assert_match "Vite Ruby can't find #{ asset_file } in #{ manifest_path }", error.message
  end

  def test_lookup_with_type_exception!
    asset_file = 'calendar'

    error = assert_raises_manifest_missing_entry_error do
      path_for(asset_file, type: :javascript)
    end

    assert_match "Vite Ruby can't find #{ asset_file }.js in #{ manifest_path }", error.message
  end

  def test_lookup_success!
    entry = {
      'file' => '/vite-production/assets/application.d9514acc.js',
      'src' => 'application.js',
      'isEntry' => true,
      'imports' => [
        { 'file' => '/vite-production/assets/vendor.880705da.js' },
        { 'file' => '/vite-production/assets/example_import.8e1fddc0.js', 'src' => 'example_import.js', 'isEntry' => true },
      ],
      'css' => [
        '/vite-production/assets/application.f510c1e9.css',
      ],
    }
    assert_equal entry['file'], path_for('application.js', type: :javascript)
    assert_equal entry, lookup!('application.js', type: :javascript)
    assert_equal entry.merge('src' => 'application.ts'), lookup!('application', type: :typescript)
  end

  def test_lookup_success_with_dev_server_running!
    entry = { 'file' => '/vite-production/application.js' }
    with_dev_server_running {
      assert_equal entry, lookup!('application.js')
    }
    entry = { 'file' => '/vite-production/application.ts' }
    with_dev_server_running {
      assert_equal entry, lookup!('application', type: :typescript)
    }
  end

  def test_lookup_nil
    assert_nil lookup('foo.js')
  end

  def test_lookup_success
    entry = { 'file' => '/vite-production/assets/styles.0e53e684.css', 'src' => 'styles.css' }
    assert_equal entry, lookup('styles.css')
    assert_equal entry, lookup('styles.css', type: :stylesheet)
    assert_equal entry, lookup('styles', type: :stylesheet)
  end

  def test_lookup_success_with_dev_server_running
    entry = { 'file' => '/vite-production/styles.css' }
    with_dev_server_running {
      assert_equal entry, lookup('styles', type: :stylesheet)
    }
  end

private

  def assert_raises_manifest_missing_entry_error(&block)
    error = nil
    ViteRuby.config.stub :auto_build, false do
      error = assert_raises(ViteRuby::Manifest::MissingEntryError, &block)
    end
    error
  end

  def manifest_path
    'public/vite-production/manifest.json'
  end
end
