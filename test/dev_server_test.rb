# frozen_string_literal: true

require "test_helper"

describe "DevServer" do
  test "not running" do
    expect(ViteRuby.instance).not_to_be(:dev_server_running?)

    refresh_config(mode: "development")

    expect(ViteRuby.instance).not_to_be(:dev_server_running?)

    running_checked_at = ViteRuby.instance.instance_variable_get(:@running_checked_at)

    assert((Time.now.to_f - running_checked_at.to_f).abs < 0.01)
  end

  test "running" do
    refresh_config(mode: "development")
    ViteRuby.instance.instance_variable_set(:@running, true)
    ViteRuby.instance.instance_variable_set(:@running_checked_at, Time.now)

    expect(ViteRuby.instance).to_be(:dev_server_running?)
  ensure
    ViteRuby.instance.remove_instance_variable(:@running)
    ViteRuby.instance.remove_instance_variable(:@running_checked_at)
  end
end
