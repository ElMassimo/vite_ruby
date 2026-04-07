# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vite_ruby/lib/tasks"
end

require "minitest/mock"
require "pry-byebug"

ENV["VITE_RUBY_SKIP_COMPATIBILITY_CHECK"] = "true"
require_relative "test_app/config/environment"
Rails.env = "production"
ViteRuby.reload_with

class MockProcessStatus
  def initialize(success: true)
    @success = success
  end

  def success?
    @success
  end
end

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
    File.expand_path("test_app", __dir__)
  end

  def with_dev_server_running(&block)
    ViteRuby.instance.stub(:dev_server_running?, true, &block)
  end

  def stub_builder(build_errors: "", build_successful: build_errors.empty?, stale: false, &block)
    original_success = ViteRuby::Build.instance_method(:success)
    original_stale = ViteRuby::Build.instance_method(:stale?)
    original_errors_method = ViteRuby::Build.instance_method(:errors)
    original_build_with_vite = ViteRuby::Builder.instance_method(:build_with_vite)

    ViteRuby::Build.define_method(:success) { build_successful }
    ViteRuby::Build.define_method(:stale?) { stale }
    ViteRuby::Build.define_method(:errors) { build_errors }
    result = ["stdout", build_errors, MockProcessStatus.new(success: build_successful)]
    ViteRuby::Builder.define_method(:build_with_vite) { |*| result }

    begin
      yield
    ensure
      ViteRuby::Build.define_method(:success, original_success)
      ViteRuby::Build.define_method(:stale?, original_stale)
      ViteRuby::Build.define_method(:errors, original_errors_method)
      ViteRuby::Builder.define_method(:build_with_vite, original_build_with_vite)
    end
  end

  def assert_run_command(*argv, flags: [])
    Dir.chdir(path_to_test_app) do
      received = nil
      Kernel.stub(:exec, ->(*args) { received = args }) do
        ViteRuby.run(argv, exec: true)
      end
      env, bin, *rest = received
      expect(env)
ViteRuby.config.to_env
      if bin.to_s.match?(%r{node_modules/.bin/vite})
        expect(rest) == [*argv, *flags]
      else
        expect(bin)
        expect(rest) == ["vite", *argv, *flags]
      end
    end
  end
end

# Add setup/teardown support and ViteRubyTestHelpers to Quickdraw::Context
class Quickdraw::Context
  include ViteRubyTestHelpers

  # Override run to call setup/teardown around each test and catch exceptions
  def run(tests)
    tests.each do |(name, skip, block)|
      @name = name
      @skip = skip

      setup
      begin
        instance_exec(&block)
      rescue => e
        failure! { "#{e.class}: #{e.message}\n#{e.backtrace.first(3).join("\n")}" }
      ensure
        teardown
      end
      resolve
    end
  end

  # Default setup/teardown: refresh ViteRuby config
  def setup
    refresh_config
  end

  def teardown
    refresh_config
  end
end
