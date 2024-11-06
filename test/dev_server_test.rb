# frozen_string_literal: true

require "test_helper"

class DevServerTest < ViteRuby::Test
  def test_not_running
    refute_predicate ViteRuby.instance, :dev_server_running?

    refresh_config(mode: "development")

    refute_predicate ViteRuby.instance, :dev_server_running?

    running_checked_at = ViteRuby.instance.instance_variable_get(:@running_checked_at)

    assert_in_delta(Time.now.to_f, running_checked_at.to_f, 0.01)
  end

  def test_running
    refresh_config(mode: "development")
    ViteRuby.instance.instance_variable_set(:@running, true)
    ViteRuby.instance.instance_variable_set(:@running_checked_at, Time.now)

    assert_predicate ViteRuby.instance, :dev_server_running?
  ensure
    ViteRuby.instance.remove_instance_variable(:@running)
    ViteRuby.instance.remove_instance_variable(:@running_checked_at)
  end
end
