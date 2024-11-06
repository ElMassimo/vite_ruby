# frozen_string_literal: true

require "test_helper"

class RakeTasksTest < ViteRuby::Test
  def test_rake_tasks
    assert ViteRuby.install_tasks
    output = Dir.chdir(path_to_test_app) { `rake -T` }

    assert_includes output, "vite:build"
    assert_includes output, "vite:build_ssr"
    assert_includes output, "vite:clobber"
    assert_includes output, "vite:install_dependencies"
    assert_includes output, "vite:verify_install"
  end

  def test_rake_task_vite_check_binstubs
    output = Dir.chdir(path_to_test_app) { `rake vite:verify_install 2>&1` }

    refute_includes output, "vite binstub not found."
  end

  def test_rake_vite_install_dependencies_in_non_production_environments
    assert_includes test_app_dev_dependencies, "right-pad"

    ViteRuby.commands.send(:with_node_env, "test") do
      Dir.chdir(path_to_test_app) do
        `bundle exec rake vite:install_dependencies`
      end
    end

    assert_includes installed_node_module_names, "right-pad",
                    "Expected dev dependencies to be installed"
  end

  def test_rake_vite_install_dependencies_in_production_environment
    ViteRuby.commands.send(:with_node_env, "production") do
      Dir.chdir(path_to_test_app) do
        `bundle exec rake vite:install_dependencies`
      end
    end

    assert_includes installed_node_module_names, "right-pad",
                    "Expected development dependencies to be installed as well"
  end

private

  def path_to_test_app
    File.expand_path("test_app", __dir__)
  end

  def test_app_dev_dependencies
    package_json = File.expand_path("package.json", path_to_test_app)
    JSON.parse(File.read(package_json))["devDependencies"]
  end

  def installed_node_module_names
    node_modules_path = File.expand_path("node_modules", path_to_test_app)
    Dir.chdir(node_modules_path) { Dir.glob("*") }
  end
end
