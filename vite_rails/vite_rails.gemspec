# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("./lib", __dir__)
require "vite_rails/version"

Gem::Specification.new do |s|
  s.name = "vite_rails"
  s.version = ViteRails::VERSION
  s.authors = ["Máximo Mussini"]
  s.email = ["maximomussini@gmail.com"]
  s.summary = "Use Vite in Rails and bring joy to your JavaScript experience"
  s.homepage = "https://github.com/ElMassimo/vite_ruby"
  s.license = "MIT"

  s.metadata = {
    "source_code_uri" => "https://github.com/ElMassimo/vite_ruby/tree/vite_rails@#{ViteRails::VERSION}/vite_rails",
    "changelog_uri" => "https://github.com/ElMassimo/vite_ruby/blob/vite_rails@#{ViteRails::VERSION}/vite_rails/CHANGELOG.md",
    "rubygems_mfa_required" => "true",
  }

  s.required_ruby_version = Gem::Requirement.new(">= 2.5")

  s.add_dependency "railties", ">= 5.1", "< 9"
  s.add_dependency "vite_ruby", ">= 3.2.2", "~> 3.0"

  s.add_development_dependency "spring", "~> 2.1"

  s.files = Dir.glob("{lib,templates}/**/*") + %w[README.md CHANGELOG.md LICENSE.txt]
end
