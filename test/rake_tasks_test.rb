# frozen_string_literal: true

require "test_helper"

describe "RakeTasks" do
  def test_app_dev_dependencies
    package_json = File.expand_path("package.json", path_to_test_app)
    JSON.parse(File.read(package_json))["devDependencies"]
  end

  def installed_node_module_names
    node_modules_path = File.expand_path("node_modules", path_to_test_app)
    Dir.chdir(node_modules_path) { Dir.glob("*") }
  end

  test "rake tasks" do
    assert(ViteRuby.install_tasks)
    output = Dir.chdir(path_to_test_app) { `"#{RAKE_BIN}" -T` }

    expect(output).to_include("vite:build")
    expect(output).to_include("vite:build_ssr")
    expect(output).to_include("vite:clobber")
    expect(output).to_include("vite:install_dependencies")
    expect(output).to_include("vite:verify_install")
  end

  test "rake task vite check binstubs" do
    output = Dir.chdir(path_to_test_app) { `"#{RAKE_BIN}" vite:verify_install 2>&1` }

    expect(output).not_to_include("vite binstub not found.")
  end

  test "rake vite install dependencies in non production environments" do
    expect(test_app_dev_dependencies).to_include("right-pad")

    ViteRuby.commands.send(:with_node_env, "test") do
      Dir.chdir(path_to_test_app) do
        `"#{RAKE_BIN}" vite:install_dependencies`
      end
    end

    expect(installed_node_module_names).to_include("right-pad")
  end

  test "rake vite install dependencies in production environment" do
    ViteRuby.commands.send(:with_node_env, "production") do
      Dir.chdir(path_to_test_app) do
        `"#{RAKE_BIN}" vite:install_dependencies`
      end
    end

    expect(installed_node_module_names).to_include("right-pad")
  end
end
