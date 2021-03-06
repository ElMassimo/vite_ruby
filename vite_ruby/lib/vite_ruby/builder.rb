# frozen_string_literal: true

require 'json'
require 'digest/sha1'

# Public: Keeps track of watched files and triggers builds as needed.
class ViteRuby::Builder
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
  end

  # Public: Checks if the watched files have changed since the last compilation,
  # and triggers a Vite build if any files have changed.
  def build(*args)
    if fresh?(build = last_build)
      if build['success']
        logger.debug "Skipping vite build. Watched files have not changed since the last build at #{ build['timestamp'] }"
      else
        logger.error "Build with vite failed! Watched files have not changed since #{ build['timestamp'] } ❌"
      end
      true
    else
      build_with_vite(*args).tap { |success| record_files_digest(success) }
    end
  end

  # Public: Returns true if all the assets built by Vite are up to date.
  def fresh?(build = last_build)
    build && build['digest'] == watched_files_digest
  end

  # Public: Returns true if any of the assets built by Vite is out of date.
  def stale?
    !fresh?
  end

  # Internal: Reads the result of the last compilation from disk.
  def last_build
    JSON.parse(files_digest_path.read.to_s) if files_digest_path.exist?
  rescue JSON::JSONError, Errno::ENOENT, Errno::ENOTDIR
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :logger

  # Internal: Writes a digest of the watched files to disk for future checks.
  def record_files_digest(success)
    config.build_cache_dir.mkpath
    build = { success: success, timestamp: Time.now.strftime('%F %T'), digest: watched_files_digest }
    files_digest_path.write(build.to_json)
  end

  # Internal: The path of where a digest of the watched files is stored.
  def files_digest_path
    config.build_cache_dir.join("last-compilation-#{ config.mode }")
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
  def build_with_vite(*args)
    logger.info 'Building with Vite ⚡️'

    stdout, stderr, status = ViteRuby.run(['build', *args], capture: true)
    log_build_result(stdout, stderr.to_s, status)

    status.success?
  end

  # Internal: Outputs the build results.
  #
  # NOTE: By default it also outputs the manifest entries.
  def log_build_result(_stdout, stderr, status)
    if status.success?
      logger.info "Build with Vite complete: #{ config.build_output_dir }"
      logger.error stderr.to_s unless stderr.empty?
    else
      logger.error stderr
      logger.error 'Build with Vite failed! ❌'
      logger.error '❌ Check that vite and vite-plugin-ruby are in devDependencies and have been installed. ' if stderr.include?('ERR! canceled')
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
