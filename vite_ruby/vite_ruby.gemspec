# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('./lib', __dir__)
require 'vite_ruby/version'

Gem::Specification.new do |s|
  s.name     = 'vite_ruby'
  s.version  = ViteRuby::VERSION
  s.authors  = ['Máximo Mussini']
  s.email    = ['maximomussini@gmail.com']
  s.summary  = 'Use Vite in Ruby and bring joy to your JavaScript experience'
  s.homepage = 'https://github.com/ElMassimo/vite_rails'
  s.license  = 'MIT'
  s.metadata = {
    'source_code_uri' => "https://github.com/ElMassimo/vite_rails/tree/vite_ruby@#{ ViteRuby::VERSION }/vite_ruby",
    'changelog_uri' => "https://github.com/ElMassimo/vite_rails/blob/vite_ruby@#{ ViteRuby::VERSION }/vite_ruby/CHANGELOG.md",
  }

  s.required_ruby_version = Gem::Requirement.new('>= 2.5')

  s.add_dependency 'dry-cli', '~> 0.6'
  s.add_dependency 'rack-proxy', '>= 0.6.1'
  s.add_dependency 'zeitwerk'

  s.add_development_dependency 'bundler', '>= 1.3.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-performance'

  s.files = Dir.glob('{lib,exe,templates}/**/*') + %w[default.vite.json README.md CHANGELOG.md CONTRIBUTING.md LICENSE.txt]
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.bindir = 'exe'
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
end
