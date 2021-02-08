# frozen_string_literal: true

require 'test_helper'

class DevServerTest < ViteRuby::Test
  def test_running?
    refute ViteRuby.instance.dev_server_running?
  end
end
