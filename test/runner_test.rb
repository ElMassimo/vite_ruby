# frozen_string_literal: true

require 'test_helper'

class RunnerTest < ViteRails::Test
  def setup
    @original_node_env, ENV['NODE_ENV'] = ENV['NODE_ENV'], 'development'
    @original_rails_env, ENV['RAILS_ENV'] = ENV['RAILS_ENV'], 'development'
  end

  def teardown
    ENV['NODE_ENV'] = @original_node_env
    ENV['RAILS_ENV'] = @original_rails_env
  end

  def test_dev_server_command
    assert_run_command(flags: ['--mode', 'development'])
  end

  def test_dev_server_command_via_yarn
    assert_run_command(flags: ['--mode', 'development'], use_yarn: true)
  end

  def test_dev_server_command_with_argument
    assert_run_command('--quiet', flags: ['--mode', 'development'])
  end

  def test_build_command
    assert_run_command('build', flags: ['--mode', 'development'])
  end

  def test_build_command_via_yarn
    assert_run_command('build', flags: ['--mode', 'development'], use_yarn: true)
  end

  def test_build_command_with_argument
    with_rails_env('production') do
      assert_run_command('build', '--emptyOutDir', flags: ['--mode', 'production'])
    end
  end
end
