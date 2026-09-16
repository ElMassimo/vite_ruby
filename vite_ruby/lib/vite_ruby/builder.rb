# frozen_string_literal: true

require "digest/sha1"

# Public: Keeps track of watched files and triggers builds as needed.
class ViteRuby::Builder
  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
    @file_digests = {}
  end

  # Public: Checks if the watched files have changed since the last compilation,
  # and triggers a Vite build if any files have changed.
  def build(*args)
    last_build = last_build_metadata(ssr: args.include?("--ssr"))

    if args.delete("--force") || last_build.stale? || config.manifest_paths.empty?
      stdout, stderr, status = build_with_vite(*args)
      log_build_result(stdout, stderr, status)
      record_build_metadata(last_build, errors: stderr, success: status.success?)
      status.success?
    elsif last_build.success
      logger.debug "Skipping vite build. Watched files have not changed since the last build at #{last_build.timestamp}"
      true
    else
      logger.error "Skipping vite build. Watched files have not changed since the build failed at #{last_build.timestamp} ❌"
      false
    end
  end

  # Internal: Reads the result of the last compilation from disk.
  def last_build_metadata(ssr: false)
    ViteRuby::Build.from_previous(last_build_path(ssr: ssr), watched_files_digest)
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :logger, :run

  # Internal: Writes a digest of the watched files to disk for future checks.
  def record_build_metadata(build, **attrs)
    config.build_cache_dir.mkpath
    build.with_result(**attrs).write_to_cache
  end

  # Internal: The file path where metadata of the last build is stored.
  def last_build_path(ssr:)
    config.build_cache_dir.join("last#{"-ssr" if ssr}-build-#{config.mode}.json")
  end

  # Internal: Returns a digest of all the watched files, allowing to detect
  # changes, and skip Vite builds if no files have changed.
  def watched_files_digest
    return @last_digest if @last_digest_at && Time.now - @last_digest_at < 1

    config.within_root do
      previous_digests = @file_digests
      @file_digests = {}
      file_ids = Dir[*config.watched_paths].sort.filter_map { |file|
        file_digest(file, previous_digests)
      }
      @last_digest_at = Time.now
      @last_digest = Digest::SHA1.hexdigest(file_ids.join("/"))
    end
  end

  # Internal: Returns the id of a watched file, or nil if it's a directory.
  #
  # NOTE: Reading and hashing every watched file dominates the cost of the
  # check, and the answer is almost always the same one as the last time, so the
  # contents are read again only once the file has been touched. The digest
  # stays content-based: a checkout that changes mtimes but not contents still
  # counts as unchanged, and no Vite build is triggered.
  def file_digest(file, previous_digests)
    stat = File.stat(file)
    return if stat.directory?

    signature = [stat.mtime, stat.size]
    previous_signature, previous_id = previous_digests[file]
    id = if previous_signature == signature && !recently_modified?(stat)
      previous_id
    else
      "#{File.basename(file)}/#{Digest::SHA1.file(file).hexdigest}"
    end
    @file_digests[file] = [signature, id]
    id
  end

  # Internal: Whether the file was modified too recently to trust its mtime.
  #
  # NOTE: A file edited twice within the resolution of the file system clock,
  # without changing its size, would keep the same signature. Rehashing the
  # files touched in the last second rules that out, the same way Git resolves
  # a racily clean entry in the index.
  def recently_modified?(stat)
    Time.now - stat.mtime < 1
  end

  # Public: Initiates a Vite build command to generate assets.
  def build_with_vite(*args)
    logger.info "Building with Vite ⚡️"

    run(["build", *args])
  end

  # Internal: Outputs the build results.
  #
  # NOTE: By default it also outputs the manifest entries.
  def log_build_result(_stdout, stderr, status)
    if status.success?
      logger.info "Build with Vite complete: #{config.build_output_dir}"
      logger.error stderr unless stderr.empty?
    else
      logger.error stderr
      logger.error status
      logger.error "Build with Vite failed! ❌"
      logger.error "❌ Check that vite and vite-plugin-ruby are in devDependencies and have been installed. " if stderr.include?("ERR! canceled")
    end
  end
end
