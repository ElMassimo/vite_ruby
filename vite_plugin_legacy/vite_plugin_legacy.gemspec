# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("./lib", __dir__)
require "vite_plugin_legacy/version"

Gem::Specification.new do |s|
  s.name = "vite_plugin_legacy"
  s.version = VitePluginLegacy::VERSION
  s.authors = ["Máximo Mussini"]
  s.email = ["maximomussini@gmail.com"]
  s.summary = "Tag helpers for @vitejs/plugin-legacy to support legacy browsers"
  s.homepage = "https://github.com/ElMassimo/vite_ruby"
  s.license = "MIT"

  s.metadata = {
    "source_code_uri" => "https://github.com/ElMassimo/vite_ruby/tree/vite_plugin_legacy@#{VitePluginLegacy::VERSION}/vite_plugin_legacy",
    "changelog_uri" => "https://github.com/ElMassimo/vite_ruby/blob/vite_plugin_legacy@#{VitePluginLegacy::VERSION}/vite_plugin_legacy/CHANGELOG.md",
    "rubygems_mfa_required" => "true",
  }

  s.required_ruby_version = Gem::Requirement.new(">= 3.3")

  s.add_dependency "vite_ruby", "~> 3.0", ">= 3.0.4"

  s.files = Dir.glob("{lib,templates}/**/*") + %w[README.md CHANGELOG.md LICENSE.txt]
end
