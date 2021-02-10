# frozen_string_literal: true

require 'dry/cli/utils/files'
require 'stringio'
require 'open3'

class ViteRuby::CLI::Install < Dry::CLI::Command
  desc 'Performs the initial configuration setup to get started with Vite Ruby.'

  def call(**)
    $stdout.sync = true

    say 'Creating binstub'
    ViteRuby.commands.install_binstubs

    say 'Creating configuration files'
    create_configuration_files

    say 'Installing sample files'
    install_sample_files

    say 'Installing js dependencies'
    install_js_dependencies

    say 'Adding files to .gitignore'
    install_gitignore

    say "\nVite ⚡️ Ruby successfully installed! 🎉"
  end

protected

  # Internal: Setup for a plain Rack application.
  def setup_app_files
    copy_template 'config/vite.json', to: config.config_path

    if (rackup_file = root.join('config.ru')).exist?
      inject_line_after_last rackup_file, 'require', 'use(ViteRuby::DevServerProxy, ssl_verify_none: true) if ViteRuby.run_proxy?'
    end
  end

  # Internal: Create a sample JS file and attempt to inject it in an HTML template.
  def install_sample_files
    copy_template 'entrypoints/application.js', to: config.resolved_entrypoints_dir.join('application.js')
  end

private

  extend Forwardable

  def_delegators 'ViteRuby', :config

  %i[append cp inject_line_after inject_line_after_last inject_line_before write].each do |util|
    define_method(util) { |*args|
      Dry::CLI::Utils::Files.send(util, *args) rescue nil
    }
  end

  TEMPLATES_PATH = Pathname.new(File.expand_path('../../../templates', __dir__))

  def copy_template(path, to:)
    cp TEMPLATES_PATH.join(path), to
  end

  # Internal: Creates the Vite and vite-plugin-ruby configuration files.
  def create_configuration_files
    copy_template 'config/vite.config.ts', to: root.join('vite.config.ts')
    setup_app_files
    ViteRuby.reload_with('VITE_RUBY_CONFIG_PATH' => config.config_path)
  end

  # Internal: Installs vite and vite-plugin-ruby at the project level.
  def install_js_dependencies
    package_json = root.join('package.json')
    write(package_json, '{}') unless package_json.exist?
    Dir.chdir(root) do
      deps = "vite@#{ ViteRuby::DEFAULT_VITE_VERSION } vite-plugin-ruby@#{ ViteRuby::DEFAULT_PLUGIN_VERSION }"
      stdout, stderr, status = Open3.capture3({ 'CI' => 'true' }, "npx ni -D #{ deps }")
      stdout, stderr, = Open3.capture3({}, "yarn add -D #{ deps }") unless status.success?
      say(stdout, "\n", stderr)
    end
  end

  # Internal: Adds compilation output dirs to git ignore.
  def install_gitignore
    return unless (gitignore_file = root.join('.gitignore')).exist?

    append(gitignore_file, <<~GITIGNORE)

      # Vite Ruby
      /public/vite
      /public/vite-dev
      /public/vite-test
      node_modules
      *.local
      .DS_Store
    GITIGNORE
  end

  # Internal: The root path for the Ruby application.
  def root
    @root ||= silent_warnings { config.root }
  end

  def say(*args)
    $stdout.puts(*args)
  end

  # Internal: Avoid printing warning about missing vite.json, we will create one.
  def silent_warnings
    old_stderr = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = old_stderr
  end
end

# NOTE: This allows framework-specific variants to extend the installation.
ViteRuby.framework_libraries.each do |_framework, library|
  require "#{ library.name }/installation"
end
