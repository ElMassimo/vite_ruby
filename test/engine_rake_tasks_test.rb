# frozen_string_literal: true

require 'test_helper'

class EngineRakeTasksTest < ViteRuby::Test
  def setup
    super
    remove_vite_files
  end

  def teardown
    remove_vite_files
    super
  end

  def test_tasks_mounted
    output = within_mounted_app { `bundle exec rake -T` }
    assert_includes output, 'app:vite'
  end

  def test_rake_tasks
    within_mounted_app { `bundle exec rake app:vite:binstubs` }
    assert vite_binstub_path.exist?

    within_mounted_app_root { `bin/vite install` }
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
    raise error, [error.message, @command_results.join("\n\n")].join("\n")
  end

  def test_cli
    # within_mounted_app_root { `bundle exec vite install` }
    # assert vite_binstub_path.exist?
    # assert vite_config_ts_path.exist?
    # assert app_frontend_dir.exist?

    # within_mounted_app_root { assert_includes `bin/vite version`, ViteRails::VERSION }

    # within_mounted_app_root { `bin/vite build` }
    # assert app_public_dir.exist?
    # assert app_public_dir.join('manifest.json').exist?
    # assert app_public_dir.join('assets').exist?
  rescue Minitest::Assertion => error
    raise error, [error.message, @command_results.join("\n\n")].join("\n")
  end

  def test_cli_commands
    within_mounted_app_root {
      refresh_config('VITE_RUBY_ROOT' => Dir.pwd)
      ViteRuby::CLI::Install.new.call
      ViteRuby.commands.verify_install
      ViteRuby::CLI::Version.new.call
      stub_runner(expect: ['--wat']) {
        assert_equal 'run', ViteRuby::CLI::Dev.new.call(mode: ViteRuby.mode, args: ['--wat'])
      }
    }
  end

private

  def within_mounted_app(&block)
    Dir.chdir(mounted_app_path, &block).tap { |result| @command_results << result }
  end

  def within_mounted_app_root(&block)
    Dir.chdir(mounted_app_path.join('test/dummy'), &block).tap { |result| @command_results << result }
  end

  def stub_runner(expect:, &block)
    mock = Minitest::Mock.new
    mock.expect(:call, 'run', [expect])
    ViteRuby.stub(:run, mock, &block)
    mock.verify
  end

  def mounted_app_path
    Pathname.new(File.expand_path(__dir__)).join('mounted_app')
  end

  def root_dir
    mounted_app_path.join('test/dummy')
  end

  def gitignore_path
    root_dir.join('.gitignore')
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
    root_dir.join('app/views/layouts/application.html.erb').write(Pathname.new(test_app_path).join('app/views/layouts/application.html.erb').read)
    gitignore_path.write('')
    @command_results = []
  end
end
