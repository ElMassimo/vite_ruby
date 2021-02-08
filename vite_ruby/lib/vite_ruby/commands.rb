# frozen_string_literal: true

# Public: Encapsulates common tasks, available both programatically and from the
# CLI and Rake tasks.
class ViteRuby::Commands
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Defaults to production, and exits if the build fails.
  def build_from_task
    with_node_env(ENV.fetch('NODE_ENV', 'production')) {
      ensure_log_goes_to_stdout {
        build || exit!
      }
    }
  end

  # Public: Builds all assets that are managed by Vite, from the entrypoints.
  def build
    builder.build.tap { manifest.refresh }
  end

  # Public: Removes all build cache and previously compiled assets.
  def clobber
    config.build_output_dir.rmtree if config.build_output_dir.exist?
    config.build_cache_dir.rmtree if config.build_cache_dir.exist?
    config.vite_cache_dir.rmtree if config.vite_cache_dir.exist?
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
      .drop_while { |(mtime, _), index|
        max_age = [0, Time.now - Time.at(mtime)].max
        max_age < age_in_seconds || index < keep_up_to
      }
      .each do |(_, files), _|
        clean_files(files)
      end
    true
  end

  # Internal: Verifies if ViteRuby is properly installed.
  def verify_install
    unless File.exist?(ViteRuby.config.root.join('bin/vite'))
      warn <<~WARN
        vite binstub not found.
        Have you run `bundle binstub vite`?
        Make sure the bin directory and bin/vite are not included in .gitignore
      WARN
    end

    config_path = ViteRuby.config.root.join(ViteRuby.config.config_path)
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
    Dir.chdir(ViteRuby.config.root) do
      $stdout.puts "Is bin/vite present?: #{ File.exist? 'bin/vite' }"

      $stdout.puts "vite_ruby: #{ ViteRuby::VERSION }"
      $stdout.puts "node: #{ `node --version` }"
      $stdout.puts "npm: #{ `npm --version` }"
      $stdout.puts "yarn: #{ `yarn --version` }"
      $stdout.puts "ruby: #{ `ruby --version` }"

      $stdout.puts "\n"
      $stdout.puts "vite-plugin-ruby: \n#{ `npm list vite-plugin-ruby version` }"
    end
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :builder, :manifest, :logger, :logger=

  def may_clean?
    config.build_output_dir.exist? && config.manifest_path.exist?
  end

  def clean_files(files)
    files.select { |file| File.file?(file) }.each do |file|
      File.delete(file)
      logger.info("Removed #{ file }")
    end
  end

  def versions
    all_files = Dir.glob("#{ config.build_output_dir }/**/*")
    entries = all_files - [config.manifest_path] - current_version_files
    entries.reject { |file| File.directory?(file) }
      .group_by { |file| File.mtime(file).utc.to_i }
      .sort.reverse
  end

  def current_version_files
    Dir.glob(manifest.refresh.values.map { |value| config.build_output_dir.join("#{ value['file'] }*") })
  end

  def with_node_env(env)
    original = ENV['NODE_ENV']
    ENV['NODE_ENV'] = env
    yield
  ensure
    ENV['NODE_ENV'] = original
  end

  def ensure_log_goes_to_stdout
    old_logger = logger
    self.logger = Logger.new($stdout)
    yield
  ensure
    self.logger = old_logger
  end
end
