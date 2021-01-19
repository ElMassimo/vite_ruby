# frozen_string_literal: true

require 'minitest/autorun'
require 'rails'
require 'rails/test_help'
require 'byebug'

require_relative 'test_app/config/environment'

Rails.env = 'production'

ViteRails.instance = ::ViteRails.new

class ViteRails::Test < Minitest::Test
private

  def reloaded_config
    ViteRails.instance.instance_variable_set(:@config, nil)
    ViteRails.instance.instance_variable_set(:@dev_server, nil)
    ViteRails.env = {}
    ViteRails.config
    ViteRails.dev_server
  end

  def with_rails_env(env)
    original = Rails.env
    Rails.env = ActiveSupport::StringInquirer.new(env)
    reloaded_config
    yield
  ensure
    Rails.env = ActiveSupport::StringInquirer.new(original)
    reloaded_config
  end
end
