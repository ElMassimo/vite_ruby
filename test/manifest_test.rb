# frozen_string_literal: true

require 'test_helper'

class ManifestTest < Minitest::Test
  def test_lookup_exception!
    asset_file = 'calendar.js'

    error = assert_raises_manifest_missing_entry_error do
      ViteRails.manifest.lookup!(asset_file)
    end

    assert_match "ViteRails can't find #{ asset_file } in #{ manifest_path }", error.message
  end

  def test_lookup_with_type_exception!
    asset_file = 'calendar'

    error = assert_raises_manifest_missing_entry_error do
      ViteRails.manifest.lookup!(asset_file, type: :javascript)
    end

    assert_match "ViteRails can't find #{ asset_file }.js in #{ manifest_path }", error.message
  end

  def test_lookup_success!
    assert_equal ViteRails.manifest.lookup!('bootstrap.js'), '/packs/bootstrap-300631c4f0e0f9c865bc.js'
  end

  def test_lookup_nil
    assert_nil ViteRails.manifest.lookup('foo.js')
  end

  def test_lookup_chunks_nil
    assert_nil ViteRails.manifest.lookup_pack_with_chunks('foo.js')
  end

  def test_lookup_success
    assert_equal ViteRails.manifest.lookup('bootstrap.js'), '/packs/bootstrap-300631c4f0e0f9c865bc.js'
  end

  def test_lookup_entrypoint_exception!
    asset_file = 'calendar'

    error = assert_raises_manifest_missing_entry_error do
      ViteRails.manifest.lookup_pack_with_chunks!(asset_file, type: :javascript)
    end

    assert_match "ViteRails can't find #{ asset_file }.js in #{ manifest_path }", error.message
  end

  def test_lookup_entrypoint
    application_entrypoints = [
      '/packs/vendors~application~bootstrap-c20632e7baf2c81200d3.chunk.js',
      '/packs/vendors~application-e55f2aae30c07fb6d82a.chunk.js',
      '/packs/application-k344a6d59eef8632c9d1.js',
    ]

    assert_equal ViteRails.manifest.lookup_pack_with_chunks!('application', type: :javascript), application_entrypoints
  end

private

  def assert_raises_manifest_missing_entry_error(&block)
    error = nil
    ViteRails.config.stub :compile?, false do
      error = assert_raises ViteRails::Manifest::MissingEntryError, &block
    end
    error
  end

  def manifest_path
    File.expand_path File.join(File.dirname(__FILE__), 'test_app/public/packs', 'manifest.json').to_s
  end
end
