# frozen_string_literal: true

require 'simplecov'
SimpleCov.start {
  add_filter '/test/'
}

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true, location: true, fast_fail: !ENV['CI'])]

require 'rails'
require 'rails/test_help'
require 'pry-byebug'

require_relative 'test_app/config/environment'
Rails.env = 'production'
ViteRuby.reload_with({})

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

  def assert_run_command(*argv, flags: [])
    Dir.chdir(test_app_path) {
      mock = Minitest::Mock.new
      mock.expect(:call, nil, [ViteRuby.config.to_env, *%w[npx nr vite], *argv, *flags])
      Kernel.stub(:exec, mock) { ViteRuby.run(argv) }
      mock.verify
    }
  end
end
