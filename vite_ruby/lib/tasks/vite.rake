# frozen_string_literal: true

$stdout.sync = true

require 'rake'

namespace :vite do
  task :binstubs do
    ViteRuby.commands.install_binstubs
  end

  desc 'Compile JavaScript packs using vite for production with digests'
  task build: :'vite:verify_install' do
    ViteRuby.commands.build_from_task
  end

  desc 'Remove old compiled vites'
  task :clean, [:keep, :age] => :'vite:verify_install' do |_, args|
    ViteRuby.commands.clean_from_task(args)
  end

  desc 'Remove the vite build output directory'
  task clobber: :'vite:verify_install' do
    ViteRuby.commands.clobber
  end

  desc 'Verifies if ViteRuby is properly installed in this application'
  task :verify_install do
    ViteRuby.commands.verify_install
  end

  desc 'Ensures build dependencies like Vite are installed when compiling assets'
  task :install_dependencies do
    system({ 'NODE_ENV' => 'development' }, 'npx --yes ci')
  end

  desc "Provide information on ViteRuby's environment"
  task :info do
    ViteRuby.commands.print_info
  end
end

if Rake::Task.task_defined?('assets:precompile')
  Rake::Task['assets:precompile'].enhance do |task|
    prefix = task.name.split(/#|assets:precompile/).first
    Rake::Task["#{ prefix }vite:build"].invoke
  end
else
  Rake::Task.define_task('assets:precompile' => ['vite:install_dependencies', 'vite:build'])
end
