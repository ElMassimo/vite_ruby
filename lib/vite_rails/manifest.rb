# frozen_string_literal: true

# Public: Registry for accessing resources managed by Vite, using a generated
# manifest file which maps entrypoint names to file paths.
#
# Example:
#   lookup_entrypoint('calendar', type: :javascript)
#   => { "file" => "/vite/assets/calendar-1016838bab065ae1e314.js", "imports" => [] }
#
# NOTE: Using "autoBuild": true` in `config/vite.json` file will trigger a build
# on demand as needed, before performing any lookup.
class ViteRails::Manifest
  class MissingEntryError < StandardError
  end

  def initialize(vite_rails)
    @vite_rails = vite_rails
  end

  # Public: Strict version of lookup.
  #
  # Returns a relative path for the asset, or raises an error if not found.
  def lookup!(*args, **options)
    lookup(*args, **options) || missing_entry_error(*args, **options)
  end

  # Public: Computes the path for a given Vite asset using manifest.json.
  #
  # Returns a relative path, or nil if the asset is not found.
  #
  # Example:
  #   ViteRails.manifest.lookup('calendar.js')
  #   # { "file" => "/vite/assets/calendar-1016838bab065ae1e122.js", "imports" => [] }
  def lookup(name, type: nil)
    build if should_build?

    find_manifest_entry(with_file_extension(name, type))
  end

  # Public: Refreshes the cached mappings by reading the updated manifest.
  def refresh
    @manifest = load_manifest
  end

  # Public: Scopes an asset to the output folder in public, as a path.
  def prefix_vite_asset(path)
    File.join("/#{ config.public_output_dir }", path)
  end

private

  delegate :config, :builder, :dev_server_running?, to: :@vite_rails

  # NOTE: Auto compilation is convenient when running tests, when the developer
  # won't focus on the frontend, or when running the Vite server is not desired.
  def should_build?
    config.auto_build && !dev_server_running?
  end

  # Internal: Finds the specified entry in the manifest.
  def find_manifest_entry(name)
    if dev_server_running?
      { 'file' => prefix_vite_asset(name.to_s) }
    else
      manifest[name.to_s]
    end
  end

  # Internal: Performs a Vite build.
  def build
    ViteRails.logger.tagged('Vite') { builder.build }
  end

  # Internal: The parsed data from manifest.json.
  #
  # NOTE: When using build-on-demand in development and testing, the manifest
  # is reloaded automatically before each lookup, to ensure it's always fresh.
  def manifest
    return refresh if config.auto_build

    @manifest ||= load_manifest
  end

  # Internal: Returns a Hash with the entries in the manifest.json.
  def load_manifest
    if config.manifest_path.exist?
      JSON.parse(config.manifest_path.read).each do |_, entry|
        entry['file'] = prefix_vite_asset(entry['file'])
        entry['css'] = prefix_vite_asset(entry['css']) if entry['css']
      end
    else
      {}
    end
  end

  # Internal: Adds a file extension to the file name, unless it already has one.
  def with_file_extension(name, entry_type)
    return name unless File.extname(name.to_s).empty?

    extension = extension_for_type(entry_type)
    extension ? "#{ name }.#{ extension }" : name
  end

  # Internal: Allows to receive :javascript and :stylesheet as :type in helpers.
  def extension_for_type(entry_type)
    case entry_type
    when :javascript then 'js'
    when :stylesheet then 'css'
    when :typescript then dev_server_running? ? 'ts' : 'js'
    else entry_type
    end
  end

  # Internal: Raises a detailed message when an entry is missing in the manifest.
  def missing_entry_error(name, type: nil, **_options)
    file_name = with_file_extension(name, type)
    raise ViteRails::Manifest::MissingEntryError, <<~MSG
      Vite Rails can't find #{ file_name } in #{ config.manifest_path }.

      Possible causes:
      #{ missing_entry_causes.map { |cause| "\t- #{ cause }" }.join("\n") }

      Your manifest contains:
      #{ JSON.pretty_generate(@manifest) }
    MSG
  end

  def missing_entry_causes
    local = config.auto_build
    [
      (dev_server_running? && 'Vite has not yet re-built your latest changes.'),
      (local && !dev_server_running? && "\"autoBuild\": false in your #{ config.mode } configuration."),
      (local && !dev_server_running? && 'The Vite development server has crashed or is no longer available.'),
      'You have misconfigured config/vite.json file.',
      (!local && 'Assets have not been precompiled'),
    ].compact
  rescue StandardError
    []
  end
end
