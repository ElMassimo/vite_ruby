# frozen_string_literal: true

source "https://rubygems.org"

gem "rails"

gemspec path: "./vite_ruby"
gemspec path: "./vite_rails"
gemspec path: "./vite_plugin_legacy"

group :development, :test do
  gem "benchmark-ips"
  gem "minitest", "~> 5.0"  # provides minitest/mock for block-scoped Object#stub utility
  gem "rubocop"
  gem "rubocop-performance"
  gem "standard", require: false
end
