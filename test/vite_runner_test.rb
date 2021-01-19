# frozen_string_literal: true

require 'test_helper'

class ViteRunnerTest < ViteRails::Test
  def setup
    @original_node_env, ENV['NODE_ENV'] = ENV['NODE_ENV'], 'development'
    @original_rails_env, ENV['RAILS_ENV'] = ENV['RAILS_ENV'], 'development'
  end

  def teardown
    ENV['NODE_ENV'] = @original_node_env
    ENV['RAILS_ENV'] = @original_rails_env
  end

  def test_run_cmd_via_node_modules
    cmd = ["#{ test_app_path }/node_modules/.bin/vite", 'build', '--mode', 'development']

    verify_command(cmd, use_node_modules: true)
  end

  def test_run_cmd_via_yarn
    cmd = ['yarn', 'vite', 'build', '--mode', 'development']

    verify_command(cmd, use_node_modules: false)
  end

  def test_run_cmd_argv
    cmd = ["#{ test_app_path }/node_modules/.bin/vite", 'build', '--mode', 'development', '--emptyOutDir']

    verify_command(cmd, argv: ['--emptyOutDir'])
  end

private

  def test_app_path
    File.expand_path('test_app', __dir__)
  end

  def verify_command(cmd, use_node_modules: true, argv: [])
    cwd = Dir.pwd
    Dir.chdir(test_app_path)

    klass = ViteRails::ViteRunner
    instance = klass.new(argv)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [ViteRails::Compiler.env, *cmd])

    klass.stub(:new, instance) do
      instance.stub(:executable_exists?, use_node_modules) do
        Kernel.stub(:exec, mock) { klass.run(argv) }
      end
    end

    mock.verify
  ensure
    Dir.chdir(cwd)
  end
end
