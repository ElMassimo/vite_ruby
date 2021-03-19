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
    @build_mutex = Mutex.new if config.auto_build
  end

  # Public: Returns the path for the specified Vite entrypoint file.
  #
  # Raises an error if the resource could not be found in the manifest.
  def path_for(name, **options)
    lookup!(name, **options).fetch('file')
  end

  # Public: Returns scripts, imported modules, and stylesheets for the specified
  # entrypoint files.
  def resolve_entries(*names, **options)
    entries = names.map { |name| lookup!(name, **options) }
    script_paths = entries.map { |entry| entry.fetch('file') }

    imports = dev_server_running? ? [] : entries.flat_map { |entry| entry['imports'] }.compact.uniq
    {
      scripts: script_paths,
      imports: imports.map { |entry| entry.fetch('file') }.uniq,
      stylesheets: dev_server_running? ? [] : (entries + imports).flat_map { |entry| entry['css'] }.compact.uniq,
    }
  end

  # Public: Refreshes the cached mappings by reading the updated manifest files.
  def refresh
    @manifest = load_manifest
  end

  # Public: The path from where the browser can download the Vite HMR client.
  def vite_client_src
    prefix_vite_asset('@vite/client') if dev_server_running?
  end

protected

  # Internal: Strict version of lookup.
  #
  # Returns a relative path for the asset, or raises an error if not found.
  def lookup!(*args, **options)
    lookup(*args, **options) || missing_entry_error(*args, **options)
  end

  # Internal: Computes the path for a given Vite asset using manifest.json.
  #
  # Returns a relative path, or nil if the asset is not found.
  #
  # Example:
  #   manifest.lookup('calendar.js')
  #   => { "file" => "/vite/assets/calendar-1016838bab065ae1e122.js", "imports" => [] }
  def lookup(name, type: nil)
    @build_mutex.synchronize { builder.build } if should_build?

    find_manifest_entry(with_file_extension(name, type))
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

  # Internal: Scopes an asset to the output folder in public, as a path.
  def prefix_vite_asset(path)
    File.join("/#{ config.public_output_dir }", path)
  end

  # Internal: Resolves the paths that reference a manifest entry.
  def resolve_references(manifest)
    manifest.each_value do |entry|
      entry['file'] = prefix_vite_asset(entry['file'])
      entry['css'] = entry['css'].map { |path| prefix_vite_asset(path) } if entry['css']
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
    last_build = builder.last_build_metadata
    raise ViteRuby::Manifest::MissingEntryError, <<~MSG
      Vite Ruby can't find #{ file_name } in #{ config.manifest_path.relative_path_from(config.root) } or #{ config.assets_manifest_path.relative_path_from(config.root) }.

      Possible causes:
      #{ possible_causes(last_build) }
      Visit the Troubleshooting guide for more information:
        https://vite-ruby.netlify.app/guide/troubleshooting.html#troubleshooting
      #{ "\nContent in your manifests:\n#{ JSON.pretty_generate(@manifest) }\n" if last_build.success }
      #{ "\nLast build in #{ config.mode } mode:\n#{ last_build.to_json }\n" unless last_build.success.nil? }
    MSG
  end

  def possible_causes(last_build)
    return FAILED_BUILD_CAUSES.sub(':mode', config.mode) if last_build.success == false
    return DEFAULT_CAUSES if config.auto_build

    DEFAULT_CAUSES + NO_AUTO_BUILD_CAUSES
  end

  FAILED_BUILD_CAUSES = <<-MSG
  - The last build failed. Try running `RACK_ENV=:mode bin/vite build --force` manually and check for errors.
  MSG

  DEFAULT_CAUSES = <<-MSG
  - The file path is incorrect.
  - The file is not in the entrypoints directory.
  - Some files are outside the sourceCodeDir, and have not been added to watchAdditionalPaths.
  MSG

  NO_AUTO_BUILD_CAUSES = <<-MSG
  - You have not run `bin/vite dev` to start Vite, or the dev server is not reachable.
  - "autoBuild" is set to `false` in your config/vite.json for this environment.
  MSG
end
