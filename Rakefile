# frozen_string_literal: true

RAKE_BIN = File.expand_path("bin/rake", __dir__)

task :test do
  $LOAD_PATH.unshift(File.expand_path("test", __dir__))
  require "quickdraw"
  require_relative "test/test_helper"

  # Patch runner to detect _test.rb files in backtraces (quickdraw normally expects .test.rb)
  Quickdraw::Runner.prepend(Module.new do
    def failure!(path, &message)
      location = caller_locations.drop_while { |l| !l.path.match?(/[_\.]test\.rb/) }
      @failures << [message, location, path]
      Kernel.print "🔴 "
    end
  end)

  test_files = Dir.glob(File.expand_path("test/**/*_test.rb", __dir__)).reject { |f|
    f.include?("/test_app/") || f.include?("/mounted_app/")
  }.sort

  result = Quickdraw::Runner.new

  test_files.each do |file|
    klass = Class.new(Quickdraw::Context) do
      class_eval(File.read(file), file, 1)
    end
    klass.run(result, [File.basename(file)])
  end

  puts
  puts "#{result.successes.count} passed, #{result.failures.count} failed in #{test_files.count} files"

  if result.failures.any?
    puts
    result.failures.each do |(message, location, path)|
      puts "FAILED: #{path.join(" > ")}"
      if location&.any?
        loc = location.first
        puts "  at #{loc.path}:#{loc.lineno}"
      end
      puts "  #{message.call}"
      puts
    end
    exit 1
  end
end

task default: :test
