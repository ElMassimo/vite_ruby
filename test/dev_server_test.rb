# frozen_string_literal: true

require "test_helper"

describe "DevServerTest" do
  include ViteRubyTestHelpers

  it "not running" do
    expect(ViteRuby.instance.dev_server_running?).to be_falsey

    refresh_config(mode: "development")

    expect(ViteRuby.instance.dev_server_running?).to be_falsey

    running_checked_at = ViteRuby.instance.instance_variable_get(:@running_checked_at)

    expect((Time.now.to_f - running_checked_at.to_f).abs).to be < 0.01
  end

  it "running" do
    refresh_config(mode: "development")
    ViteRuby.instance.instance_variable_set(:@running, true)
    ViteRuby.instance.instance_variable_set(:@running_checked_at, Time.now)

    expect(ViteRuby.instance.dev_server_running?).to be_truthy

    ViteRuby.instance.remove_instance_variable(:@running)
    ViteRuby.instance.remove_instance_variable(:@running_checked_at)
  end
end
