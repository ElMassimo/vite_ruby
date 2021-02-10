source "https://rubygems.org"

gemspec path: "../vite_rails"
gem 'vite_ruby', path: '../vite_ruby'

gem "rails", "~> 6.0.0"
gem "rake", ">= 11.1"
gem "rack-proxy", require: false
gem "minitest", "~> 5.0"
gem 'minitest-reporters'
gem "pry-byebug"
gem "spring"
gem "simplecov", '< 0.18'

group :test do
  gem "m"
end
