# frozen_string_literal: true

require "benchmark/ips"
require "bundler/setup"

REGEX = %r{^/}

Benchmark.ips do |x|
  x.config(time: 3, warmup: 1)

  path = "/application.ts"

  x.report("start_with? [1..-1]") { path.start_with?("/") ? path[1..] : path }
  x.report("sub %r{^/}") { path.sub(%r{^/}, "") }
  x.report("sub REGEX") { path.sub(REGEX, "") }
  x.compare!
end
