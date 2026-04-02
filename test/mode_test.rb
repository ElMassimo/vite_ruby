# frozen_string_literal: true

require "test_helper"

describe "ModeTest" do
  include ViteRubyTestHelpers

  it "mode" do
    expect(ViteRuby.config.mode).to be == Rails.env
    expect(ViteRuby.mode).to be == ViteRuby.config.mode
  end

  it "mode with rails env" do
    with_rails_env("staging") do |config|
      expect(config.mode).to be == "staging"
    end
  end
end
