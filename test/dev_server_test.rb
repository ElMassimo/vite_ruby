# frozen_string_literal: true

require 'test_helper'

class DevServerTest < ViteRails::Test
  def test_running?
    refute ViteRails.dev_server.running?
  end
end
