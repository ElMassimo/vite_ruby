# frozen_string_literal: true

require "test_helper"

describe "Mode" do
  test "mode" do
    expect(ViteRuby.config.mode) == Rails.env
    expect(ViteRuby.mode) == ViteRuby.config.mode
  end

  test "mode with rails env" do
    with_rails_env("staging") do |config|
      expect(config.mode) == "staging"
    end
  end
end
