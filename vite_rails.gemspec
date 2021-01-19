# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('./lib', __dir__)
require 'vite_rails/version'

Gem::Specification.new do |s|
  s.name     = 'vite_rails'
  s.version  = ViteRails::VERSION
  s.authors  = ['Máximo Mussini']
  s.email    = ['maximomussini@gmail.com']
  s.summary  = 'Use Vite in Rails and bring joy to your JavaScript experience'
  s.homepage = 'https://github.com/ElMassimo/vite_rails'
  s.license  = 'MIT'

  s.metadata = {
    'source_code_uri' => "https://github.com/ElMassimo/vite_rails/tree/v#{ ViteRails::VERSION }",
    'changelog_uri' => "https://github.com/ElMassimo/vite_rails/blob/v#{ ViteRails::VERSION }/CHANGELOG.md",
  }

  s.required_ruby_version = '>= 2.4.0'

  s.add_dependency 'activesupport', '>= 5.1'
  s.add_dependency 'rack-proxy',    '>= 0.6.1'
  s.add_dependency 'railties',      '>= 5.1'
  s.add_dependency 'zeitwerk'

  s.add_development_dependency 'bundler', '>= 1.3.0'
  s.add_development_dependency 'rubocop', '0.93.1'
  s.add_development_dependency 'rubocop-performance'

  s.files = Dir.glob('{lib}/**/*.{rb,rake}') + %w[package.json package/default.vite.json README.md CHANGELOG.md CONTRIBUTING.md LICENSE.txt]
  s.test_files = `git ls-files -- test/*`.split("\n")
end
