# frozen_string_literal: true

require 'test_helper'

class DevServerTest < ViteRails::Test
  def test_running?
    refute ViteRails.dev_server.running?
  end

  def test_host
    with_rails_env('development') do
      assert_equal ViteRails.config.host, 'localhost'
    end
  end

  def test_port
    with_rails_env('development') do
      assert_equal ViteRails.config.port, 3035
    end
  end

  def test_https?
    with_rails_env('development') do
      assert_equal ViteRails.config.https, false
    end
  end

  def test_protocol
    with_rails_env('development') do
      assert_equal ViteRails.config.protocol, 'http'
    end
  end

  def test_host_with_port
    with_rails_env('development') do
      assert_equal ViteRails.config.host_with_port, 'localhost:3035'
    end
  end
end
