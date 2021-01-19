# frozen_string_literal: true

require 'test_helper'

class ViteRailsTest < ViteRails::Test
  def test_config_params
    assert_equal Rails.env, ViteRails.config.mode
    assert_equal ViteRails.instance.root_path, ViteRails.config.root_path
    assert_equal ViteRails.instance.config_path, ViteRails.config.config_path

    with_rails_env('test') do
      assert_equal 'test', ViteRails.config.env
    end
  end
end
