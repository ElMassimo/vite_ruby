# frozen_string_literal: true

require "benchmark/ips"
require "bundler/setup"

Benchmark.ips do |x|
  x.config(time: 3, warmup: 1)

  dir = Pathname.new(__dir__).join("..")

  x.report("Pathname#file?") { dir.join("Gemfile").file? }
  x.report("Pathname#exist?") { dir.join("Gemfile").exist? }
  x.report("File.exist?") { File.exist?("#{dir}/Gemfile") }
  x.report("File.file?") { File.file?("#{dir}/Gemfile") }
  x.report("File.exist? w/join") { File.exist?(dir.join("Gemfile")) }
  x.report("File.file? w/join") { File.file?(dir.join("Gemfile")) }

  x.compare!
end
