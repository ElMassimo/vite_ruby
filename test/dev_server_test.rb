# frozen_string_literal: true

require 'test_helper'

class DevServerTest < ViteRuby::Test
  def test_not_running
    refute ViteRuby.instance.dev_server_running?

    refresh_config(mode: 'development')
    refute ViteRuby.instance.dev_server_running?
  end

  def test_running
    refresh_config(mode: 'development')
    ViteRuby.instance.instance_variable_set('@running_at', Time.now)
    assert ViteRuby.instance.dev_server_running?
  ensure
    ViteRuby.instance.remove_instance_variable('@running_at')
  end
end
