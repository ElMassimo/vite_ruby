# frozen_string_literal: true

binstubs_template_path = File.expand_path('../../install/binstubs.rb', __dir__).freeze
bin_path = ENV['BUNDLE_BIN'] || Rails.root.join('bin')

namespace :vite do
  desc 'Installs Vite binstubs in this application'
  task :binstubs do |task|
    prefix = task.name.split(/#|vite:binstubs/).first
    exec "#{ RbConfig.ruby } #{ bin_path }/rails #{ prefix }app:template LOCATION=#{ binstubs_template_path }"
  end
end
