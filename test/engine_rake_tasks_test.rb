# frozen_string_literal: true

require 'test_helper'

class EngineRakeTasksTest < Minitest::Test
  def setup
    remove_vite_files
  end

  def teardown
    remove_vite_files
  end

  def test_tasks_mounted
    output = within_mounted_app { `bundle exec rake -T` }
    assert_includes output, 'app:vite'
  end

  def test_rake_tasks
    within_mounted_app { `bundle exec rake app:vite:binstubs` }
    assert vite_binstub_path.exist?

    within_mounted_app { `bundle exec rake app:vite:install` }
    assert vite_config_ts_path.exist?
    assert app_frontend_dir.exist?

    within_mounted_app { `bundle exec rake app:vite:build` }
    assert app_public_dir.exist?
    assert app_public_dir.join('manifest.json').exist?
    assert app_public_dir.join('assets').exist?

    within_mounted_app { `bundle exec rake app:vite:clean` }
    assert app_public_dir.join('manifest.json').exist? # Still fresh

    within_mounted_app { `bundle exec rake app:vite:clean[0,0]` }
    refute app_public_dir.join('manifest.json').exist?

    within_mounted_app { `bundle exec rake app:vite:clobber` }
    refute app_public_dir.exist?
  rescue Minitest::Assertion => error
    raise error unless Rails.gem_version.prerelease?
  end

private

  def within_mounted_app
    Dir.chdir(mounted_app_path) { yield }
  end

  def mounted_app_path
    Pathname.new(File.expand_path(__dir__)).join('mounted_app')
  end

  def root_dir
    mounted_app_path.join('test/dummy')
  end

  def vite_binstub_path
    root_dir.join('bin/vite')
  end

  def vite_config_ts_path
    root_dir.join('vite.config.ts')
  end

  def app_frontend_dir
    root_dir.join('app/frontend')
  end

  def app_public_dir
    root_dir.join('public/vite-dev')
  end

  def remove_vite_files
    vite_binstub_path.delete if vite_binstub_path.exist?
    vite_config_ts_path.delete if vite_config_ts_path.exist?
    app_frontend_dir.rmtree if app_frontend_dir.exist?
    app_public_dir.rmtree if app_public_dir.exist?
  end
end
