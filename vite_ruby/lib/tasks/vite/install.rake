# frozen_string_literal: true

install_template_path = File.expand_path('../../install/template.rb', __dir__).freeze
bin_path = ENV['BUNDLE_BIN'] || Rails.root.join('bin')

namespace :vite do
  desc 'Install ViteRails in this application'
  task :install do |task|
    prefix = task.name.split(/#|vite:install/).first
    exec "#{ RbConfig.ruby } #{ bin_path }/rails #{ prefix }app:template LOCATION=#{ install_template_path }"
  end
end
