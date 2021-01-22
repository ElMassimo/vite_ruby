# frozen_string_literal: true

require 'test_helper'

class EngineRakeTasksTest < Minitest::Test
  def setup
    remove_vite_binstub
  end

  def teardown
    remove_vite_binstub
  end

  def test_tasks_mounted
    output = Dir.chdir(mounted_app_path) { `bundle exec rake -T` }
    assert_includes output, 'app:vite'
  end

  def test_binstub
    Dir.chdir(mounted_app_path) { `bundle exec rake app:vite:binstubs` }
    assert File.exist?(vite_binstub_path)
  end

private

  def mounted_app_path
    File.expand_path('mounted_app', __dir__)
  end

  def vite_binstub_path
    "#{ mounted_app_path }/test/dummy/bin/vite"
  end

  def remove_vite_binstub
    File.delete(vite_binstub_path) if File.exist?(vite_binstub_path)
  end
end
