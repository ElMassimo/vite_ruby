# frozen_string_literal: true

require "test_helper"

class CompatibilityCheckTest < ViteRuby::Test
  delegate :verify_plugin_version, :raise_unless_satisfied, :compatible_plugin?, to: "ViteRuby::CompatibilityCheck"

  def test_verify_plugin_version
    refresh_config(skip_compatibility_check: true)
    assert_raises(ArgumentError) { refresh_config(skip_compatibility_check: false) }
  end

  def test_compatible_plugin
    refute compatible_plugin?("^3.1.0", "^3.0.1")
    refute compatible_plugin?("^4.1.0", "^3.0")
    refute compatible_plugin?("4.1.0", "^3.0")

    assert compatible_plugin?("3.0.5", "^3.0.1")
    assert compatible_plugin?("^3.0.9", "^3.0.1")
    assert compatible_plugin?("3.1.0", "^3.0")
    assert compatible_plugin?("^3.1.0", "^3.0")
    assert compatible_plugin?(nil, "^3.0")
    assert compatible_plugin?(nil, nil)
  end

  def test_requires_plugin_version_with_mode_specific_metadata
    assert_equal "^5.2.5", ViteRuby::DEFAULT_PLUGIN_VERSION
    refute compatible_plugin?("^5.2.4", ViteRuby::DEFAULT_PLUGIN_VERSION)
    assert compatible_plugin?("^5.2.5", ViteRuby::DEFAULT_PLUGIN_VERSION)
  end

  def test_raise_unless_satisfied
    assert_raises(ArgumentError) { raise_unless_satisfied("^4.1.0", "^3.0") }
    raise_unless_satisfied("3.1.0", "^3.0")
    raise_unless_satisfied(nil, "^3.0")
  end
end
