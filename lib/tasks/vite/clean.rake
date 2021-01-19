# frozen_string_literal: true

$stdout.sync = true

namespace :vite do
  desc 'Remove old compiled vites'
  task :clean, [:keep, :age] => [:'vite:verify_install', :environment] do |_, args|
    ViteRails.ensure_log_goes_to_stdout do
      ViteRails.clean(keep_up_to: Integer(args.keep || 2), age_in_seconds: Integer(args.age || 3600))
    end
  end
end

skip_vite_clean = %w[no false n f].include?(ENV['VITE_RUBY_PRECOMPILE'])

unless skip_vite_clean
  # Run clean if the assets:clean is run
  if Rake::Task.task_defined?('assets:clean')
    Rake::Task['assets:clean'].enhance do
      Rake::Task['vite:clean'].invoke
    end
  else
    Rake::Task.define_task('assets:clean' => 'vite:clean')
  end
end
