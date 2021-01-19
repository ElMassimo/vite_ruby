# frozen_string_literal: true

$stdout.sync = true

def enhance_assets_precompile
  Rake::Task['assets:precompile'] do |task|
    prefix = task.name.split(/#|assets:precompile/).first

    Rake::Task["#{ prefix }vite:build"].invoke
  end
end

namespace :vite do
  desc 'Compile JavaScript packs using vite for production with digests'
  task build: [:'vite:verify_install', :environment] do
    ViteRails.with_node_env(ENV.fetch('NODE_ENV', 'production')) do
      ViteRails.ensure_log_goes_to_stdout do
        ViteRails.build || exit!
      end
    end
  end
end

# Compile packs after we've compiled all other assets during precompilation
skip_vite_precompile = %w[no false n f].include?(ENV['VITE_RUBY_PRECOMPILE'])

unless skip_vite_precompile
  if Rake::Task.task_defined?('assets:precompile')
    enhance_assets_precompile
  else
    Rake::Task.define_task('assets:precompile' => [:'vite:install_dependencies', :'vite:build'])
  end
end
