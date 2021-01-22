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
end
