# frozen_string_literal: true

require 'digest/sha1'

# Public: Keeps track of watched files and triggers builds as needed.
class ViteRuby::Builder
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Checks if the watched files have changed since the last compilation,
  # and triggers a Vite build if any files have changed.
  def build
    if stale?
      build_with_vite.tap { record_files_digest }
    else
      logger.debug 'Skipping build. Vite assets are already up-to-date ⚡️'
      true
    end
  end

  # Public: Returns true if all the assets built by Vite are up to date.
  def fresh?
    previous_files_digest&.== watched_files_digest
  end

  # Public: Returns true if any of the assets built by Vite is out of date.
  def stale?
    !fresh?
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :logger

  # Internal: Writes a digest of the watched files to disk for future checks.
  def record_files_digest
    config.build_cache_dir.mkpath
    files_digest_path.write(watched_files_digest)
  end

  # Internal: The path of where a digest of the watched files is stored.
  def files_digest_path
    config.build_cache_dir.join("last-compilation-digest-#{ config.mode }")
  end

  # Internal: Reads a digest of watched files from disk.
  def previous_files_digest
    files_digest_path.read if files_digest_path.exist? && config.manifest_path.exist?
  rescue Errno::ENOENT, Errno::ENOTDIR
  end

  # Internal: Returns a digest of all the watched files, allowing to detect
  # changes, and skip Vite builds if no files have changed.
  def watched_files_digest
    Dir.chdir File.expand_path(config.root) do
      files = Dir[*watched_paths].reject { |f| File.directory?(f) }
      file_ids = files.sort.map { |f| "#{ File.basename(f) }/#{ Digest::SHA1.file(f).hexdigest }" }
      Digest::SHA1.hexdigest(file_ids.join('/'))
    end
  end

  # Public: Initiates a Vite build command to generate assets.
  #
  # Returns true if the build is successful, or false if it failed.
  def build_with_vite
    logger.info 'Building with Vite ⚡️'

    stdout, stderr, status = ViteRuby.run(['build'], capture: true)
    log_build_result(stdout, stderr, status)

    status.success?
  end

  # Internal: Outputs the build results.
  #
  # NOTE: By default it also outputs the manifest entries.
  def log_build_result(stdout, stderr, status)
    if status.success?
      logger.info "Build with Vite complete: #{ config.build_output_dir }"
      logger.error(stderr.to_s) unless stderr.empty?
      logger.info(stdout) unless config.hide_build_console_output
    else
      non_empty_streams = [stdout, stderr].delete_if(&:empty?)
      errors = non_empty_streams.join("\n\n")
      errors += "\n❌ Check that vite and vite-plugin-ruby are in devDependencies and have been installed. " if errors.include?('ERR! canceled')
      logger.error "Build with Vite failed:\n#{ errors }"
    end
  end

  # Internal: Files and directories that should be watched for changes.
  #
  # NOTE: You can specify additional ones in vite.json using "watchAdditionalPaths": [...]
  def watched_paths
    [
      *config.watch_additional_paths,
      "#{ config.source_code_dir }/**/*",
      'yarn.lock',
      'package.json',
      config.config_path,
    ].freeze
  end
end
