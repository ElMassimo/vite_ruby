# frozen_string_literal: true

require 'test_helper'

class CommandTest < Minitest::Test
  def test_compile_command_returns_success_status_when_stale
    ViteRails.builder.stub :stale?, true do
      ViteRails.builder.stub :run_vite, true do
        assert_equal true, ViteRails.commands.compile
      end
    end
  end

  def test_compile_command_returns_success_status_when_fresh
    ViteRails.builder.stub :stale?, false do
      ViteRails.builder.stub :run_vite, true do
        assert_equal true, ViteRails.commands.compile
      end
    end
  end

  def test_compile_command_returns_failure_status_when_stale
    ViteRails.builder.stub :stale?, true do
      ViteRails.builder.stub :run_vite, false do
        assert_equal false, ViteRails.commands.compile
      end
    end
  end

  def test_clean_command_works_with_nested_hashes_and_without_any_compiled_files
    File.stub :delete, true do
      assert ViteRails.commands.clean
    end
  end
end
