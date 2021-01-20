# frozen_string_literal: true

namespace :vite do
  desc "Provide information on ViteRails's environment"
  task :info do
    Dir.chdir(Rails.root) do
      $stdout.puts "Ruby: #{ `ruby --version` }"
      $stdout.puts "Rails: #{ Rails.version }"
      $stdout.puts "ViteRails: #{ ViteRails::VERSION }"
      $stdout.puts "Node: #{ `node --version` }"
      $stdout.puts "Yarn: #{ `yarn --version` }"

      $stdout.puts "\n"
      $stdout.puts "vite-plugin-ruby: \n#{ `npm list vite-plugin-ruby version` }"

      $stdout.puts "Is bin/vite present?: #{ File.exist? 'bin/vite' }"
      $stdout.puts "Is bin/yarn present?: #{ File.exist? 'bin/yarn' }"
    end
  end
end
