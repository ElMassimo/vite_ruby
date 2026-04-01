# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ViteRuby mode" do
  it "mode" do
    expect(ViteRuby.config.mode).to eq(Rails.env.to_s)
    expect(ViteRuby.mode).to eq(ViteRuby.config.mode)
  end

  it "mode_with_rails_env" do
    with_rails_env("staging") do |config|
      expect(config.mode).to eq("staging")
    end
  end
end
