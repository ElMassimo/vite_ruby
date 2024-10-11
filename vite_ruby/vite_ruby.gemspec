# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('./lib', __dir__)
require 'vite_ruby/version'

Gem::Specification.new do |s|
  s.name     = 'vite_ruby'
  s.version  = ViteRuby::VERSION
  s.authors  = ['Máximo Mussini']
  s.email    = ['maximomussini@gmail.com']
  s.summary  = 'Use Vite in Ruby and bring joy to your JavaScript experience'
  s.homepage = 'https://github.com/ElMassimo/vite_ruby'
  s.license  = 'MIT'
  s.metadata = {
    'source_code_uri' => "https://github.com/ElMassimo/vite_ruby/tree/vite_ruby@#{ ViteRuby::VERSION }/vite_ruby",
    'changelog_uri' => "https://github.com/ElMassimo/vite_ruby/blob/vite_ruby@#{ ViteRuby::VERSION }/vite_ruby/CHANGELOG.md",
  }

  s.required_ruby_version = Gem::Requirement.new('>= 2.5')

  s.add_dependency 'dry-cli', '>= 0.7', '< 2'
  s.add_dependency 'logger', '~> 1.6'
  s.add_dependency 'rack-proxy', '~> 0.6', '>= 0.6.1'
  s.add_dependency 'zeitwerk', '~> 2.2'

  s.add_development_dependency 'm', '~> 1.5'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'minitest-reporters', '~> 1.4'
  s.add_development_dependency 'minitest-stub_any_instance', '~> 1.0'
  s.add_development_dependency 'pry-byebug', '~> 3.9'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'simplecov', '< 0.18'

  s.files = Dir.glob('{lib,exe,templates}/**/*') + %w[default.vite.json README.md CHANGELOG.md LICENSE.txt]
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.bindir = 'exe'
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.post_install_message = "Thanks for installing Vite Ruby!\n\nIf you upgraded the gem manually, please run:\n\tbundle exec vite upgrade"
end
