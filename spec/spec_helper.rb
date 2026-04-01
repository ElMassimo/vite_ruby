# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vite_ruby/lib/tasks"
end

# Provides Object#stub for block-scoped stubbing (used in with_dev_server_running, etc.)
require "minitest/mock"
require "pry-byebug"

# Load the Rails app environment first (rspec/rails must come after)
ENV["VITE_RUBY_SKIP_COMPATIBILITY_CHECK"] = "true"
require File.expand_path("../test/test_app/config/environment", __dir__)
Rails.env = "production"
ViteRuby.reload_with

require "rspec/rails"
require "action_view/test_case"  # for ActionView::TestCase used in helper_spec

module ViteRubyTestHelpers
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
    File.expand_path("../test/test_app", __dir__)
  end

  def with_dev_server_running(&block)
    ViteRuby.instance.stub(:dev_server_running?, true, &block)
  end
end

class MockProcessStatus
  def initialize(success: true)
    @success = success
  end

  def success?
    @success
  end
end

RSpec.configure do |config|
  config.include ViteRubyTestHelpers

  config.before(:each) do
    refresh_config
  end

  config.after(:each) do
    refresh_config
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false
  end

  # Helpers mirroring ViteRuby::Test base class
  config.include(Module.new do
    def stub_builder(build_errors: "", build_successful: build_errors.empty?, stale: false)
      allow_any_instance_of(ViteRuby::Build).to receive(:success).and_return(build_successful)
      allow_any_instance_of(ViteRuby::Build).to receive(:stale?).and_return(stale)
      allow_any_instance_of(ViteRuby::Build).to receive(:errors).and_return(build_errors)
      result = ["stdout", build_errors, MockProcessStatus.new(success: build_successful)]
      allow_any_instance_of(ViteRuby::Builder).to receive(:build_with_vite).and_return(result)
      yield
    end

    def assert_run_command(*argv, flags: [])
      Dir.chdir(path_to_test_app) do
        received_args = nil
        allow(Kernel).to receive(:exec) { |*args| received_args = args }
        ViteRuby.run(argv, exec: true)
        received_env, bin, *rest = received_args
        expect(received_env).to eq(ViteRuby.config.to_env)
        if bin.to_s.match?(%r{node_modules/.bin/vite})
          expect(rest).to eq([*argv, *flags])
        else
          # yarn vite path: [env, "yarn", "vite", *argv, *flags]
          expect(bin).to eq("yarn")
          expect(rest).to eq(["vite", *argv, *flags])
        end
      end
    end
  end)
end
