# frozen_string_literal: true

require 'test_helper'

class ModeTest < ViteRails::Test
  def test_mode
    assert_equal Rails.env, ViteRails.config.mode
    assert_equal ViteRails.config.mode, ViteRails.mode
  end

  def test_mode_with_rails_env
    with_rails_env('staging') do |config|
      assert_equal 'staging', config.mode
    end
  end
end
