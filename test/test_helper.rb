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
  def before
    super
    refresh_config
  end

  def after(error = nil)
    refresh_config
    super
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
    File.expand_path("test_app", __dir__)
  end

  def with_dev_server_running(&block)
    ViteRuby.instance.stub(:dev_server_running?, true, &block)
  end

  def stub_builder(build_errors: "", build_successful: build_errors.empty?, stale: false)
    build_result = ["stdout", build_errors, MockProcessStatus.new(success: build_successful)]
    original_success = ViteRuby::Build.instance_method(:success)
    original_stale = ViteRuby::Build.instance_method(:stale?)
    original_errors = ViteRuby::Build.instance_method(:errors)
    original_build_with_vite = ViteRuby::Builder.instance_method(:build_with_vite)
    ViteRuby::Build.define_method(:success) { build_successful }
    ViteRuby::Build.define_method(:stale?) { stale }
    ViteRuby::Build.define_method(:errors) { build_errors }
    ViteRuby::Builder.define_method(:build_with_vite) { |*_args| build_result }
    yield
  ensure
    ViteRuby::Build.define_method(:success, original_success)
    ViteRuby::Build.define_method(:stale?, original_stale)
    ViteRuby::Build.define_method(:errors, original_errors)
    ViteRuby::Builder.define_method(:build_with_vite, original_build_with_vite)
  end

  def assert_run_command(*argv, flags: [])
    Dir.chdir(path_to_test_app) do
      received_args = nil
      Kernel.stub(:exec, ->(*args) { received_args = args }) do
        ViteRuby.run(argv, exec: true)
      end
      received_env, bin, *rest = received_args
      expect(received_env).to be == ViteRuby.config.to_env
      if bin.to_s.match?(%r{node_modules/.bin/vite})
        expect(rest).to be == [*argv, *flags]
      else
        expect(bin).to be == "yarn"
        expect(rest).to be == ["vite", *argv, *flags]
      end
    end
  end
end
