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
    assert_run_command('vite', '--mode', 'development')
  end

  def test_run_cmd_via_yarn
    assert_run_command('yarn', 'vite', '--mode', 'development', use_node_modules: false)
  end

  def test_run_cmd_argv
    assert_run_command('vite', '--mode', 'development', argv: ['--quiet'])
  end
end
