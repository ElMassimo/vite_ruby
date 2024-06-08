# frozen_string_literal: true

require 'simplecov'
SimpleCov.start {
  add_filter '/test/'
  add_filter '/vite_ruby/lib/tasks'
}

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/stub_any_instance'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true, location: true, fast_fail: true)]

require 'rails'
require 'rails/test_help'
require 'pry-byebug'

ENV['VITE_RUBY_SKIP_COMPATIBILITY_CHECK'] = 'true'
require_relative 'test_app/config/environment'
Rails.env = 'production'
ViteRuby.reload_with

module ViteRubyTestHelpers
  def setup
    refresh_config
  end

  def teardown
    refresh_config
  end

  def refresh_config(**options)
    ViteRuby.reload_with(**options).config
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

  def path_to_test_app
    File.expand_path('test_app', __dir__)
  end

  def with_dev_server_running(&block)
    ViteRuby.instance.stub(:dev_server_running?, true, &block)
  end
end

class ViteRuby::Test < Minitest::Test
  include ViteRubyTestHelpers

private

  def stub_builder(build_errors: '', build_successful: build_errors.empty?, stale: false, &block)
    ViteRuby::Build.stub_any_instance(:success, build_successful) {
      ViteRuby::Build.stub_any_instance(:stale?, stale) {
        ViteRuby::Build.stub_any_instance(:errors, build_errors) {
          result = ['stdout', build_errors, MockProcessStatus.new(success: build_successful)]
          ViteRuby::Builder.stub_any_instance(:build_with_vite, result, &block)
        }
      }
    }
  end

  def assert_run_command(*argv, flags: [])
    Dir.chdir(path_to_test_app) {
      begin
        mock = Minitest::Mock.new
        mock.expect(:call, nil, [ViteRuby.config.to_env, %r{node_modules/.bin/vite}, *argv, *flags])
        Kernel.stub(:exec, mock) { ViteRuby.run(argv, exec: true) }
        mock.verify
      rescue ArgumentError => _error
        mock = Minitest::Mock.new
        mock.expect(:call, nil, [ViteRuby.config.to_env, 'yarn', 'vite', *argv, *flags])
        Kernel.stub(:exec, mock) { ViteRuby.run(argv, exec: true) }
        mock.verify
      end
    }
  end

  class MockProcessStatus
    def initialize(success: true)
      @success = success
    end

    def success?
      @success
    end
  end
end
