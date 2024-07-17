# frozen_string_literal: true

# Public: Encapsulates common tasks, available both programatically and from the
# CLI and Rake tasks.
class ViteRuby::Commands
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Defaults to production, and exits if the build fails.
  def build_from_task(*args)
    with_node_env(ENV.fetch('NODE_ENV', 'production')) {
      ensure_log_goes_to_stdout {
        build(*args) || exit!
      }
    }
  end

  # Public: Builds all assets that are managed by Vite, from the entrypoints.
  def build(*args)
    builder.build(*args).tap { manifest.refresh }
  end

  # Public: Removes all build cache and previously compiled assets.
  def clobber
    dirs = [config.build_output_dir, config.ssr_output_dir, config.build_cache_dir, config.vite_cache_dir]
    dirs.each { |dir| dir.rmtree if dir.exist? }
    $stdout.puts "Removed vite cache and output dirs:\n\t#{ dirs.join("\n\t") }"
  end

  # Public: Receives arguments from a rake task.
  def clean_from_task(args)
    ensure_log_goes_to_stdout {
      clean(keep_up_to: Integer(args.keep || 2), age_in_seconds: Integer(args.age || 3600))
    }
  end

  # Public: Cleanup old assets in the output directory.
  #
  # keep_up_to - Max amount of backups to preserve.
  # age_in_seconds - Amount of time to look back in order to preserve them.
  #
  # NOTE: By default keeps the last version, or 2 if created in the past hour.
  #
  # Examples:
  #   To force only 1 backup to be kept: clean(1, 0)
  #   To only keep files created within the last 10 minutes: clean(0, 600)
  def clean(keep_up_to: 2, age_in_seconds: 3600)
    return false unless may_clean?

    versions
      .each_with_index
      .drop_while { |(mtime, _files), index|
        max_age = [0, Time.now - Time.at(mtime)].max
        max_age < age_in_seconds || index < keep_up_to
      }
      .each do |(_, files), _|
        clean_files(files)
      end
    true
  end

  # Internal: Installs the binstub for the CLI in the appropriate path.
  def install_binstubs
    `bundle binstub vite_ruby --path #{ config.root.join('bin') }`
    `bundle config --delete bin`
  end

  # Internal: Checks if the npm version is 6 or lower.
  def legacy_npm_version?
    `npm --version`.to_i < 7 rescue false
  end

  # Internal: Checks if the yarn version is 1.x.
  def legacy_yarn_version?
    `yarn --version`.to_i < 2 rescue false
  end

  # Internal: Verifies if ViteRuby is properly installed.
  def verify_install
    unless File.exist?(config.root.join('bin/vite'))
      warn <<~WARN

        vite binstub not found.
        Have you run `bundle binstub vite_ruby`?
        Make sure the bin directory and bin/vite are not included in .gitignore
      WARN
    end

    config_path = config.root.join(config.config_path)
    unless config_path.exist?
      warn <<~WARN

        Configuration #{ config_path } file for vite-plugin-ruby not found.
        Make sure `bundle exec vite install` has run successfully before running dependent tasks.
      WARN
      exit!
    end
  end

  # Internal: Prints information about ViteRuby's environment.
  def print_info
    config.within_root do
      $stdout.puts "bin/vite present?: #{ File.exist? 'bin/vite' }"

      $stdout.puts "vite_ruby: #{ ViteRuby::VERSION }"
      ViteRuby.framework_libraries.each do |framework, library|
        $stdout.puts "#{ library.name }: #{ library.version }"
        $stdout.puts "#{ framework }: #{ Gem.loaded_specs[framework]&.version }"
      end

      $stdout.puts "ruby: #{ `ruby --version` }"
      $stdout.puts "node: #{ `node --version` }"

      pkg = config.package_manager
      $stdout.puts "#{ pkg }: #{ `#{ pkg } --version` rescue nil }"

      $stdout.puts "\n"
      packages = `npm ls vite vite-plugin-ruby`
      packages_msg = packages.include?('vite@') ? "installed packages:\n#{ packages }" : '❌ Check that vite and vite-plugin-ruby have been added as development dependencies and installed.'
      $stdout.puts packages_msg

      ViteRuby::CompatibilityCheck.verify_plugin_version(config.root)
    end
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :builder, :manifest, :logger, :logger=

  def may_clean?
    config.build_output_dir.exist? && config.manifest_paths.any?
  end

  def clean_files(files)
    files.select { |file| File.file?(file) }.each do |file|
      File.delete(file)
      logger.info("Removed #{ file }")
    end
  end

  def versions
    all_files = Dir.glob("#{ config.build_output_dir }/**/*", File::FNM_DOTMATCH)
    entries = all_files - config.manifest_paths.map(&:to_s) - files_to_retain
    entries.reject { |file| File.directory?(file) }
      .group_by { |file| File.mtime(file).utc.to_i }
      .sort.reverse
  end

  def files_referenced_in_manifests
    config.manifest_paths.flat_map { |path|
      JSON.parse(path.read).flat_map do |_, entry|
        [entry['file']] + entry.fetch('css', []) + entry.fetch('assets', [])
      end
    }.compact.uniq.map { |path| config.build_output_dir.join(path).to_s }
  end

  def files_to_retain
    Dir.glob(files_referenced_in_manifests.map { |path| "#{ path }*" }).flatten
  end

  def with_node_env(env)
    original = ENV['NODE_ENV']
    ENV['NODE_ENV'] = env
    yield
  ensure
    ENV['NODE_ENV'] = original
  end

  def ensure_log_goes_to_stdout
    old_logger, original_sync = logger, $stdout.sync

    $stdout.sync = true
    self.logger = Logger.new($stdout, formatter: proc { |_, _, progname, msg| progname == 'vite' ? msg : "#{ msg }\n" })
    yield
  ensure
    self.logger, $stdout.sync = old_logger, original_sync
  end
end
