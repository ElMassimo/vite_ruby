# frozen_string_literal: true

require "test_helper"

class DevServerTest < ViteRuby::Test
  def test_not_running_without_meta_file
    refresh_config(mode: "development")
    remove_meta_file

    refute_predicate ViteRuby.instance, :dev_server_running?
  end

  def test_running_with_meta_file
    refresh_config(mode: "development")
    write_meta_file(url: "http://localhost:3535", host: "localhost", port: ViteRuby.config.port, https: false, pid: 1234)

    assert_predicate ViteRuby.instance, :dev_server_running?
    assert_equal "http://localhost:3535", ViteRuby.instance.send(:dev_server_meta)["url"]
  ensure
    remove_meta_file
  end

  def test_development_meta_does_not_mark_test_server_as_running
    refresh_config(mode: "test")
    remove_meta_file
    test_port = ViteRuby.config.port
    refresh_config(mode: "development", port: test_port)
    write_meta_file(port: test_port)

    refresh_config(mode: "test")

    ENV.stub(:[], ->(key) { ENV.fetch(key, nil) unless key == "CI" }) do
      refute_predicate ViteRuby.instance, :dev_server_running?
    end
  ensure
    remove_meta_file if ViteRuby.config.mode == "test"
    refresh_config(mode: "development")
    remove_meta_file
  end

  def test_running_with_test_meta_file
    refresh_config(mode: "test")
    write_meta_file(port: ViteRuby.config.port)

    ENV.stub(:[], ->(key) { ENV.fetch(key, nil) unless key == "CI" }) do
      assert_predicate ViteRuby.instance, :dev_server_running?
    end
  ensure
    remove_meta_file
  end

  def test_not_running_when_meta_port_does_not_match
    refresh_config(mode: "development")
    write_meta_file(port: ViteRuby.config.port + 1)

    refute_predicate ViteRuby.instance, :dev_server_running?
  ensure
    remove_meta_file
  end

  def test_not_running_with_invalid_meta_shape
    refresh_config(mode: "development")
    path = ViteRuby.config.dev_server_meta_path
    path.dirname.mkpath
    path.write(JSON.generate("not a metadata object"))

    refute_predicate ViteRuby.instance, :dev_server_running?
  ensure
    remove_meta_file
  end

  def test_not_running_in_production
    refresh_config(mode: "production")
    write_meta_file(url: "http://localhost:3036")

    refute_predicate ViteRuby.instance, :dev_server_running?
  ensure
    remove_meta_file
  end

  def test_connection_check_ignores_meta_file_when_socket_refused
    refresh_config(mode: "development", dev_server_connection_check: true)
    write_meta_file(url: "http://localhost:3036")

    Socket.stub(:tcp, ->(*) { raise Errno::ECONNREFUSED }) do
      refute_predicate ViteRuby.instance, :dev_server_running?
    end
  ensure
    remove_meta_file
  end

  def test_connection_check_reports_running_when_socket_connects
    refresh_config(mode: "development", dev_server_connection_check: true)
    remove_meta_file

    Socket.stub(:tcp, ->(*) { FakeSocket.new }) do
      assert_predicate ViteRuby.instance, :dev_server_running?
    end
  end

private

  def write_meta_file(**meta)
    path = ViteRuby.config.dev_server_meta_path
    path.dirname.mkpath
    path.write(JSON.generate(meta))
  end

  def remove_meta_file
    path = ViteRuby.config.dev_server_meta_path
    path.delete if path.exist?
  end

  class FakeSocket
    def close
    end
  end
end
