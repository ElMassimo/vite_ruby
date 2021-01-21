# frozen_string_literal: true

require 'test_helper'

class CommandTest < Minitest::Test
  def stub_builder(stale:, build_with_vite:)
    ViteRails.builder.stub :stale?, stale do
      ViteRails.builder.stub :build_with_vite, build_with_vite do
        yield
      end
    end
  end

  def test_compile_command_returns_success_status_when_stale
    stub_builder(stale: true, build_with_vite: true) {
      assert_equal true, ViteRails.build
    }
  end

  def test_compile_command_returns_success_status_when_fresh
    stub_builder(stale: false, build_with_vite: true) {
      assert_equal true, ViteRails.build
    }
  end

  def test_compile_command_returns_failure_status_when_stale
    stub_builder(stale: true, build_with_vite: false) {
      assert_equal false, ViteRails.build
    }
  end

  def test_clean_command_works_with_nested_hashes_and_without_any_compiled_files
    File.stub(:delete, true) {
      assert ViteRails.clean
    }
  end
end
