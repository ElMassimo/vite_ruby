# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ViteRuby::CompatibilityCheck" do
  delegate :verify_plugin_version, :raise_unless_satisfied, :compatible_plugin?, to: "ViteRuby::CompatibilityCheck"

  it "verify_plugin_version" do
    refresh_config(skip_compatibility_check: true)
    expect { refresh_config(skip_compatibility_check: false) }.to raise_error(ArgumentError)
  end

  it "compatible_plugin" do
    expect(compatible_plugin?("^3.1.0", "^3.0.1")).to be_falsy
    expect(compatible_plugin?("^4.1.0", "^3.0")).to be_falsy
    expect(compatible_plugin?("4.1.0", "^3.0")).to be_falsy

    expect(compatible_plugin?("3.0.5", "^3.0.1")).to be_truthy
    expect(compatible_plugin?("^3.0.9", "^3.0.1")).to be_truthy
    expect(compatible_plugin?("3.1.0", "^3.0")).to be_truthy
    expect(compatible_plugin?("^3.1.0", "^3.0")).to be_truthy
    expect(compatible_plugin?(nil, "^3.0")).to be_truthy
    expect(compatible_plugin?(nil, nil)).to be_truthy
  end

  it "raise_unless_satisfied" do
    expect { raise_unless_satisfied("^4.1.0", "^3.0") }.to raise_error(ArgumentError)
    expect { raise_unless_satisfied("3.1.0", "^3.0") }.not_to raise_error
    expect { raise_unless_satisfied(nil, "^3.0") }.not_to raise_error
  end
end
