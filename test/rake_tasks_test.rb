# frozen_string_literal: true

require 'test_helper'

class RakeTasksTest < Minitest::Test
  def test_rake_tasks
    output = Dir.chdir(test_app_path) { `rake -T` }
    assert_includes output, 'vite_rails'
    assert_includes output, 'vite:check_binstubs'
    assert_includes output, 'vite:check_node'
    assert_includes output, 'vite:check_yarn'
    assert_includes output, 'vite:clean'
    assert_includes output, 'vite:clobber'
    assert_includes output, 'vite:compile'
    assert_includes output, 'vite:install'
    assert_includes output, 'vite:verify_install'
  end

  def test_rake_task_vite_check_binstubs
    output = Dir.chdir(test_app_path) { `rake vite:check_binstubs 2>&1` }
    refute_includes output, 'vite binstub not found.'
  end

  def test_check_node_version
    output = Dir.chdir(test_app_path) { `rake vite:check_node 2>&1` }
    refute_includes output, 'ViteRails requires Node.js'
  end

  def test_check_yarn_version
    output = Dir.chdir(test_app_path) { `rake vite:check_yarn 2>&1` }
    refute_includes output, 'Yarn not installed'
    refute_includes output, 'ViteRails requires Yarn'
  end

  def test_rake_vite_install_dependencies_in_non_production_environments
    assert_includes test_app_dev_dependencies, 'right-pad'

    ViteRails.with_node_env('test') do
      Dir.chdir(test_app_path) do
        `bundle exec rake vite:install_dependencies`
      end
    end

    assert_includes installed_node_module_names, 'right-pad',
                    'Expected dev dependencies to be installed'
  end

  def test_rake_vite_install_dependencies_in_production_environment
    ViteRails.with_node_env('production') do
      Dir.chdir(test_app_path) do
        `bundle exec rake vite:install_dependencies`
      end
    end

    refute_includes installed_node_module_names, 'right-pad',
                    'Expected only production dependencies to be installed'
  end

private

  def test_app_path
    File.expand_path('test_app', __dir__)
  end

  def test_app_dev_dependencies
    package_json = File.expand_path('package.json', test_app_path)
    JSON.parse(File.read(package_json))['devDependencies']
  end

  def installed_node_module_names
    node_modules_path = File.expand_path('node_modules', test_app_path)
    Dir.chdir(node_modules_path) { Dir.glob('*') }
  end
end
