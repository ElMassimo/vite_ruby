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
class ViteRuby::Manifest
  class MissingEntryError < StandardError
  end

  def initialize(vite_ruby)
    @vite_ruby = vite_ruby
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
  #   ViteRuby.manifest.lookup('calendar.js')
  #   # { "file" => "/vite/assets/calendar-1016838bab065ae1e122.js", "imports" => [] }
  def lookup(name, type: nil)
    build if should_build?

    find_manifest_entry(with_file_extension(name, type))
  end

  # Public: Refreshes the cached mappings by reading the updated manifest files.
  def refresh
    @manifest = load_manifest
  end

  # Public: Scopes an asset to the output folder in public, as a path.
  def prefix_vite_asset(path)
    File.join("/#{ config.public_output_dir }", path)
  end

private

  extend Forwardable

  def_delegators :@vite_ruby, :config, :builder, :dev_server_running?

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
    builder.build
  end

  # Internal: The parsed data from manifest.json.
  #
  # NOTE: When using build-on-demand in development and testing, the manifest
  # is reloaded automatically before each lookup, to ensure it's always fresh.
  def manifest
    return refresh if config.auto_build

    @manifest ||= load_manifest
  end

  # Internal: Loads and merges the manifest files, resolving the asset paths.
  def load_manifest
    files = [config.manifest_path, config.assets_manifest_path].select(&:exist?)
    files.map { |path| JSON.parse(path.read) }.inject({}, &:merge).tap(&method(:resolve_references))
  end

  # Internal: Resolves the paths that reference a manifest entry.
  def resolve_references(manifest)
    manifest.each_value do |entry|
      entry['file'] = prefix_vite_asset(entry['file'])
      entry['css'] = Array.wrap(entry['css']).map { |path| prefix_vite_asset(path) } if entry['css']
      entry['imports']&.map! { |name| manifest.fetch(name) }
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
    when :typescript then 'ts'
    else entry_type
    end
  end

  # Internal: Raises a detailed message when an entry is missing in the manifest.
  def missing_entry_error(name, type: nil, **_options)
    file_name = with_file_extension(name, type)
    raise ViteRuby::Manifest::MissingEntryError, <<~MSG
      Vite Ruby can't find #{ file_name } in #{ config.manifest_path } or #{ config.assets_manifest_path }.

      Possible causes:
      #{ missing_entry_causes.map { |cause| "\t- #{ cause }" }.join("\n") }

      Content in your manifests:
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
    ].select(&:itself)
  rescue StandardError
    []
  end
end
