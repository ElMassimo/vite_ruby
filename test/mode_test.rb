# frozen_string_literal: true

require 'test_helper'

class ModeTest < ViteRails::Test
  def test_current
    assert_equal ViteRails.config.mode, Rails.env
  end

  def test_custom_without_config
    with_rails_env('foo') do
      assert_equal ViteRails.config.mode, 'production'
    end
  end

  def test_custom_with_config
    with_rails_env('staging') do
      assert_equal ViteRails.config.mode, 'staging'
    end
  end
end
