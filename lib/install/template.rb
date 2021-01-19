# frozen_string_literal: true

# Install Vite Rails
say 'Creating configuration files'
copy_file "#{ __dir__ }/config/vite.json", ViteRails.config.config_path
copy_file "#{ __dir__ }/config/vite.config.ts", Rails.root

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

install = if Rails.root.join('yarn.lock').exist?
  'yarn add'
elsif Rails.root.join('pnpm-lock.yaml').exist?
  'pnpm install'
else
  'npm install'
end

Dir.chdir(Rails.root) do
  say 'Installing JavaScript dependencies for Vite Rails'
  package_json = File.read("#{ __dir__ }/../../package.json")

  vite_version = package_json.match(/"vite": "(.*)"/)[1]
  plugin_version = package_json.match(/"vite-plugin-ruby": "(.*)"/)[1]

  say 'Installing vite as direct dependencies'
  run "#{ install } vite@#{ vite_version } vite-plugin-ruby@#{ plugin_version }"
end

if Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR > 1
  src = begin
          "#{ ViteRails.config.protocol }://#{ ViteRails.config.host_with_port }"
        rescue StandardError
          'http://localhost:3036'
        end
  say 'You need to allow vite-dev-server host as allowed origin for connect-src.', :yellow
  say 'This can be done in Rails 5.2+ for development environment in the CSP initializer', :yellow
  say 'config/initializers/content_security_policy.rb with a snippet like this:', :yellow
  say %(policy.connect_src :self, :https, "http://#{ src }", "ws://#{ src }" if Rails.env.development?), :yellow
end

say 'ViteRails successfully installed 🎉 🍰', :green
