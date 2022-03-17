# frozen_string_literal: true

require 'vite_ruby'
ViteRuby.install_tasks
Rake::Task['vite:verify_install'].enhance(:environment) if Rake::Task.task_defined?(:environment)
