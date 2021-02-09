# frozen_string_literal: true

require 'test_helper'

class DevServerTest < ViteRuby::Test
  def test_not_running
    refute ViteRuby.instance.dev_server_running?

    refresh_config('VITE_RUBY_MODE' => 'development')
    refute ViteRuby.instance.dev_server_running?
  end

  def test_running
    refresh_config('VITE_RUBY_MODE' => 'development')
    ViteRuby.instance.instance_variable_set('@running_at', Time.now)
    assert ViteRuby.instance.dev_server_running?
  end
end
