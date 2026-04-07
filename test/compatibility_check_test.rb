# frozen_string_literal: true

require "test_helper"

describe "CompatibilityCheck" do
  delegate :verify_plugin_version, :raise_unless_satisfied, :compatible_plugin?, to: "ViteRuby::CompatibilityCheck"

  test "verify plugin version" do
    refresh_config(skip_compatibility_check: true)
    expect { refresh_config(skip_compatibility_check: false) }.to_raise(ArgumentError)
  end

  test "compatible plugin" do
    refute(compatible_plugin?("^3.1.0", "^3.0.1"))
    refute(compatible_plugin?("^4.1.0", "^3.0"))
    refute(compatible_plugin?("4.1.0", "^3.0"))

    assert(compatible_plugin?("3.0.5", "^3.0.1"))
    assert(compatible_plugin?("^3.0.9", "^3.0.1"))
    assert(compatible_plugin?("3.1.0", "^3.0"))
    assert(compatible_plugin?("^3.1.0", "^3.0"))
    assert(compatible_plugin?(nil, "^3.0"))
    assert(compatible_plugin?(nil, nil))
  end

  test "raise unless satisfied" do
    expect { raise_unless_satisfied("^4.1.0", "^3.0") }.to_raise(ArgumentError)
    raise_unless_satisfied("3.1.0", "^3.0")
    raise_unless_satisfied(nil, "^3.0")
  end
end
