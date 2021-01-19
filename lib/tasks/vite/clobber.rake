# frozen_string_literal: true

namespace :vite do
  desc 'Remove the vite build output directory'
  task clobber: [:'vite:verify_install', :environment] do
    ViteRails.clobber
    $stdout.puts "Removed vite build output directory #{ ViteRails.config.build_output_dir }"
  end
end

skip_vite_clobber = %w[no false n f].include?(ENV['VITE_RUBY_PRECOMPILE'])

unless skip_vite_clobber
  # Run clobber if the assets:clobber is run
  if Rake::Task.task_defined?('assets:clobber')
    Rake::Task['assets:clobber'].enhance do
      Rake::Task['vite:clobber'].invoke
    end
  end
end
