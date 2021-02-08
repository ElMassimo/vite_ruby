# frozen_string_literal: true

$stdout.sync = true

require 'vite_ruby'

namespace :vite do
  desc 'Compile JavaScript packs using vite for production with digests'
  task build: :'vite:verify_install' do
    ViteRuby.commands.build_from_rake
  end

  desc 'Remove old compiled vites'
  task :clean, [:keep, :age] => :'vite:verify_install' do |_, args|
    ViteRuby.commands.clean_from_rake(args)
  end

  desc 'Remove the vite build output directory'
  task clobber: :'vite:verify_install' do
    ViteRuby.commands.clobber
    $stdout.puts "Removed vite build output directory #{ ViteRuby.config.build_output_dir }"
  end

  desc 'Verifies if ViteRuby is properly installed in this application'
  task :verify_install do
    ViteRuby.commands.verify_install
  end

  desc 'Install all JavaScript dependencies'
  task :install_dependencies do
    valid_node_envs = %w[test development production]
    rack_env = ENV.fetch('RACK_ENV', 'production')
    node_env = ENV.fetch('NODE_ENV') { valid_node_envs.include?(rack_env) ? rack_env : 'production' }
    system({ 'NODE_ENV' => node_env }, 'npx ci --prod=false')
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
