# frozen_string_literal: true

require "test_helper"

class ModeTest < ViteRuby::Test
  def test_mode
    assert_equal Rails.env, ViteRuby.config.mode
    assert_equal ViteRuby.config.mode, ViteRuby.mode
  end

  def test_mode_with_rails_env
    with_rails_env("staging") do |config|
      assert_equal "staging", config.mode
    end
  end
end
