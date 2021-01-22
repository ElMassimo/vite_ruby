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
      assert_equal false, ViteRails.build_from_rake
    }
  end

  def test_clean_command_works_with_nested_hashes_and_without_any_compiled_files
    File.stub(:delete, true) {
      assert ViteRails.clean
      assert ViteRails.clean_from_rake(OpenStruct.new)
    }
  end
end
