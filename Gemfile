# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rack-proxy', require: false
gem 'rails'
gem 'rake', '>= 11.1'

gemspec path: './vite_rails'
gem 'vite_ruby', path: './vite_ruby'

group :development, :test do
  gem 'm'
  gem 'minitest', '~> 5.0'
  gem 'minitest-reporters'
  gem 'pry-byebug'
  gem 'simplecov', '< 0.18'
  gem 'spring'
end
