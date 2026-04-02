# frozen_string_literal: true

task :test do
  require "sus/config"
  require "sus"

  config = Sus::Config.load(arguments: [])
  registry = config.registry
  assertions = Sus::Assertions.default
  config.before_tests(assertions)
  registry.call(assertions)
  config.after_tests(assertions)

  exit(1) unless assertions.passed?
end

task default: :test
