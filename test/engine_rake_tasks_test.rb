# frozen_string_literal: true

require 'test_helper'

class EngineRakeTasksTest < Minitest::Test
  def setup
    remove_vite_binstubs
  end

  def teardown
    remove_vite_binstubs
  end

  def test_task_mounted
    output = Dir.chdir(mounted_app_path) { `rake -T` }
    assert_includes output, 'app:vite'
  end

  def test_binstubs
    Dir.chdir(mounted_app_path) { `bundle exec rake app:vite:binstubs` }
    vite_binstub_paths.each { |path| assert File.exist?(path) }
  end

private

  def mounted_app_path
    File.expand_path('mounted_app', __dir__)
  end

  def vite_binstub_paths
    [
      "#{ mounted_app_path }/test/dummy/bin/vite",
      "#{ mounted_app_path }/test/dummy/bin/vite-dev-server",
    ]
  end

  def remove_vite_binstubs
    vite_binstub_paths.each do |path|
      File.delete(path) if File.exist?(path)
    end
  end
end
