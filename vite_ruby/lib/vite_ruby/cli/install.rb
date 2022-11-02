# frozen_string_literal: true

require 'stringio'

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

  # Internal: The JS packages that should be added to the app.
  def js_dependencies
    [
      "vite@#{ ViteRuby::DEFAULT_VITE_VERSION }",
      "vite-plugin-ruby@#{ ViteRuby::DEFAULT_PLUGIN_VERSION }",
    ]
  end

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

  %i[append cp inject_line_after inject_line_after_last inject_line_before replace_first_line write].each do |util|
    define_method(util) { |*args|
      ViteRuby::CLI::FileUtils.send(util, *args) rescue nil
    }
  end

  TEMPLATES_PATH = Pathname.new(File.expand_path('../../../templates', __dir__))

  def copy_template(path, to:)
    cp TEMPLATES_PATH.join(path), to
  end

  # Internal: Creates the Vite and vite-plugin-ruby configuration files.
  def create_configuration_files
    copy_template 'config/vite.config.ts', to: root.join('vite.config.ts')
    append root.join('Procfile.dev'), 'vite: bin/vite dev'
    setup_app_files
    ViteRuby.reload_with(config_path: config.config_path)
  end

  # Internal: Installs vite and vite-plugin-ruby at the project level.
  def install_js_dependencies
    package_json = root.join('package.json')
    write(package_json, '{}') unless package_json.exist?
    deps = js_dependencies.join(' ')
    run_with_capture("#{ npm_install } -D #{ deps }", stdin_data: "\n")
  end

  # Internal: Adds compilation output dirs to git ignore.
  def install_gitignore
    return unless (gitignore_file = root.join('.gitignore')).exist?

    append(gitignore_file, <<~GITIGNORE)

      # Vite Ruby
      /public/vite*
      node_modules
      # Vite uses dotenv and suggests to ignore local-only env files. See
      # https://vitejs.dev/guide/env-and-mode.html#env-files
      *.local
    GITIGNORE
  end

  # Internal: The root path for the Ruby application.
  def root
    @root ||= silent_warnings { config.root }
  end

  def say(*args)
    $stdout.puts(*args)
  end

  def run_with_capture(*args, **options)
    Dir.chdir(root) do
      _, stderr, status = ViteRuby::IO.capture(*args, **options)
      say(stderr) unless status.success? || stderr.empty?
    end
  end

  # Internal: Support all popular package managers.
  def npm_install
    return 'yarn add' if root.join('yarn.lock').exist?
    return 'pnpm install' if root.join('pnpm-lock.yaml').exist?

    'npm install'
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
