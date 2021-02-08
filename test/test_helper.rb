# frozen_string_literal: true

require 'simplecov'
SimpleCov.start {
  add_filter '/test/'
}

require 'minitest/autorun'
require 'rails'
require 'rails/test_help'
require 'pry-byebug'

require_relative 'test_app/config/environment'
Rails.env = 'production'

module ViteRubyTestHelpers
  def refresh_config(env_variables = ViteRuby.load_env_variables)
    ViteRuby.reload_with(env_variables)
  end

  def with_rails_env(env)
    original = Rails.env
    Rails.env = ActiveSupport::StringInquirer.new(env)
    refresh_config
    yield(ViteRuby.config)
  ensure
    Rails.env = ActiveSupport::StringInquirer.new(original)
    refresh_config
  end

  def test_app_path
    File.expand_path('test_app', __dir__)
  end

  def with_dev_server_running(&block)
    ViteRuby.instance.stub(:dev_server_running?, true, &block)
  end
end

class ViteRuby::Test < Minitest::Test
  include ViteRubyTestHelpers

private

  def assert_run_command(*argv, use_yarn: false, flags: [])
    command = use_yarn ? %w[yarn vite] : ["#{ test_app_path }/node_modules/.bin/vite"]
    cwd = Dir.pwd
    Dir.chdir(test_app_path)

    klass = ViteRuby::Runner
    instance = klass.new(argv)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [ViteRuby.config.to_env, *command, *argv, *flags])

    klass.stub(:new, instance) do
      instance.stub(:executable_exists?, !use_yarn) do
        Kernel.stub(:exec, mock) { ViteRuby.run(argv) }
      end
    end

    mock.verify
  ensure
    Dir.chdir(cwd)
  end
end
