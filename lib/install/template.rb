# frozen_string_literal: true

# Install Vite Rails
say 'Creating configuration files'
copy_file "#{ __dir__ }/config/vite.json", ViteRails.config.config_path
copy_file "#{ __dir__ }/config/vite.config.ts", Rails.root.join('vite.config.ts')

say 'Creating entrypoints directory'
directory "#{ __dir__ }/javascript/entrypoints", ViteRails.config.source_code_dir.join(ViteRails.config.entrypoints_dir)

apply "#{ __dir__ }/binstubs.rb"

git_ignore_path = Rails.root.join('.gitignore')
if git_ignore_path.exist?
  append_to_file(git_ignore_path) {
    <<~GITIGNORE

      # Vite on Rails
      /public/vite
      /public/vite-dev
      /public/vite-test
      node_modules
      *.local
      .DS_Store
    GITIGNORE
  }
end

Dir.chdir(Rails.root) do
  say 'Installing JavaScript dependencies for Vite Rails'
  package_json = File.read("#{ __dir__ }/../../package.json")

  vite_version = package_json.match(/"vite": "(.*)"/)[1]
  plugin_version = package_json.match(/"vite-plugin-ruby": "(.*)"/)[1]

  say 'Installing vite as direct dependencies'
  run "yarn add vite@#{ vite_version } vite-plugin-ruby@#{ plugin_version }"
end

say 'Vite ⚡️ Rails successfully installed! 🎉', :green
