# frozen_string_literal: true

# Public: Encapsulates common tasks, available both programatically and in Rake.
class ViteRails::Commands
  def initialize(vite_rails)
    @vite_rails = vite_rails
  end

  # Public: Loads the manifest with all the entries compiled by Vite.
  def bootstrap
    manifest.refresh
  end

  # Public: Builds all assets that are managed by Vite, from the entrypoints.
  def build
    builder.build.tap { manifest.refresh }
  end

  # Public: Removes all build cache and previously compiled assets.
  def clobber
    config.build_output_dir.rmtree if config.build_output_dir.exist?
    config.build_cache_dir.rmtree if config.build_cache_dir.exist?
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

private

  delegate :config, :builder, :manifest, :logger, to: :@vite_rails

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
end
