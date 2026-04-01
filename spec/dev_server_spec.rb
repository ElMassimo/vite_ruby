# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ViteRuby dev server" do
  it "not_running" do
    expect(ViteRuby.instance).not_to be_dev_server_running

    refresh_config(mode: "development")

    expect(ViteRuby.instance).not_to be_dev_server_running

    running_checked_at = ViteRuby.instance.instance_variable_get(:@running_checked_at)
    expect(Time.now.to_f).to be_within(0.01).of(running_checked_at.to_f)
  end

  it "running" do
    refresh_config(mode: "development")
    ViteRuby.instance.instance_variable_set(:@running, true)
    ViteRuby.instance.instance_variable_set(:@running_checked_at, Time.now)

    expect(ViteRuby.instance).to be_dev_server_running
  ensure
    ViteRuby.instance.remove_instance_variable(:@running)
    ViteRuby.instance.remove_instance_variable(:@running_checked_at)
  end
end
