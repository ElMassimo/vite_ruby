# frozen_string_literal: true

require "test_helper"

RAKE_BIN = File.expand_path("../bin/rake", __dir__)

describe "RakeTasksTest" do
  include ViteRubyTestHelpers

  it "rake_tasks" do
    expect(ViteRuby.install_tasks).to be_truthy
    output = Dir.chdir(path_to_test_app) { `#{RAKE_BIN} -T` }

    expect(output).to be(:include?, "vite:build")
    expect(output).to be(:include?, "vite:build_ssr")
    expect(output).to be(:include?, "vite:clobber")
    expect(output).to be(:include?, "vite:install_dependencies")
    expect(output).to be(:include?, "vite:verify_install")
  end

  it "rake_task_vite_check_binstubs" do
    output = Dir.chdir(path_to_test_app) { `#{RAKE_BIN} vite:verify_install 2>&1` }

    expect(output).not.to be(:include?, "vite binstub not found.")
  end

  it "rake_vite_install_dependencies_in_non_production_environments" do
    expect(test_app_dev_dependencies).to be(:include?, "right-pad")

    ViteRuby.commands.send(:with_node_env, "test") do
      Dir.chdir(path_to_test_app) do
        `#{RAKE_BIN} vite:install_dependencies`
      end
    end

    expect(installed_node_module_names).to be(:include?, "right-pad")
  end

  it "rake_vite_install_dependencies_in_production_environment" do
    ViteRuby.commands.send(:with_node_env, "production") do
      Dir.chdir(path_to_test_app) do
        `#{RAKE_BIN} vite:install_dependencies`
      end
    end

    expect(installed_node_module_names).to be(:include?, "right-pad")
  end

private

  def test_app_dev_dependencies
    package_json = File.expand_path("package.json", path_to_test_app)
    JSON.parse(File.read(package_json))["devDependencies"]
  end

  def installed_node_module_names
    node_modules_path = File.expand_path("node_modules", path_to_test_app)
    Dir.chdir(node_modules_path) { Dir.glob("*") }
  end
end
