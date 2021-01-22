# frozen_string_literal: true

require 'minitest/autorun'
require 'rails'
require 'rails/test_help'
require 'pry-byebug'

require_relative 'test_app/config/environment'

Rails.env = 'production'

ViteRails.instance = ViteRails.new

class ViteRails::Test < Minitest::Test
private

  def refresh_config(env_variables = ViteRails.load_env_variables)
    ViteRails.env = env_variables
    (ViteRails.instance = ViteRails.new).config
  end

  def with_rails_env(env)
    original = Rails.env
    Rails.env = ActiveSupport::StringInquirer.new(env)
    yield(refresh_config)
  ensure
    Rails.env = ActiveSupport::StringInquirer.new(original)
    refresh_config
  end

  def test_app_path
    File.expand_path('test_app', __dir__)
  end

  def assert_run_command(*cmd, use_node_modules: true, argv: [])
    command, *flags = cmd
    command = "#{ test_app_path }/node_modules/.bin/#{ command }" if use_node_modules
    cwd = Dir.pwd
    Dir.chdir(test_app_path)

    klass = ViteRails::Runner
    instance = klass.new(argv)
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [ViteRails.env, command, *argv, *flags])

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
