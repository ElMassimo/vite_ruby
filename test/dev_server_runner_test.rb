# frozen_string_literal: true

require 'test_helper'

class DevServerRunnerTest < ViteRails::Test
  def setup
    @original_node_env, ENV['NODE_ENV'] = ENV['NODE_ENV'], 'development'
    @original_rails_env, ENV['RAILS_ENV'] = ENV['RAILS_ENV'], 'development'
  end

  def teardown
    ENV['NODE_ENV'] = @original_node_env
    ENV['RAILS_ENV'] = @original_rails_env
  end

  def test_run_cmd_via_node_modules
    cmd = ["#{ test_app_path }/node_modules/.bin/vite", '--mode', 'development']

    verify_command(cmd, use_node_modules: true)
  end

  def test_run_cmd_via_yarn
    cmd = ['yarn', 'vite', '--mode', 'development']

    verify_command(cmd, use_node_modules: false)
  end

  def test_run_cmd_argv
    cmd = ["#{ test_app_path }/node_modules/.bin/vite", '--quiet', '--mode', 'development']

    verify_command(cmd, argv: ['--quiet'])
  end

  def test_run_cmd_argv_with_https
    cmd = ["#{ test_app_path }/node_modules/.bin/vite", '--https', '--mode', 'development']

    dev_server = ViteRails::DevServer.new({})
    def dev_server.host
      'localhost'
    end

    def dev_server.port
      '3035'
    end

    def dev_server.pretty?
      false
    end

    def dev_server.https?
      true
    end
    ViteRails::DevServer.stub(:new, dev_server) do
      verify_command(cmd, argv: ['--https'])
    end
  end

private

  def test_app_path
    File.expand_path('test_app', __dir__)
  end

  def verify_command(cmd, use_node_modules: true, argv: [])
    cwd = Dir.pwd
    Dir.chdir(test_app_path)

    klass = ViteRails::Runner
    instance = klass.new(argv)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [ViteRails.env, *cmd])

    klass.stub(:new, instance) do
      instance.stub(:executable_exists?, use_node_modules) do
        Kernel.stub(:exec, mock) { ViteRails.run(argv) }
      end
    end

    mock.verify
  ensure
    Dir.chdir(cwd)
  end
end
