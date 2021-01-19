# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module ViteRails::Helper
  # Public: Returns the current Vite Rails instance.
  def current_vite_instance
    ViteRails.instance
  end

  # Public: Computes the relative path for the specified given Vite asset.
  #
  # Example:
  #   <%= vite_asset_path 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
  def vite_asset_path(name, **options)
    current_vite_instance.manifest.lookup!(name, **options)
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  def vite_javascript_tag(*names, type: 'module', **options)
    javascript_include_tag(*sources_from_vite_manifest_entrypoints(names, type: :javascript), type: type, **options)
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  #
  # NOTE: Because TypeScript is not a valid target in browsers, we only specify
  # the ts file when running the Vite development server.
  def vite_typescript_tag(*names, type: 'module', **options)
    javascript_include_tag(*sources_from_vite_manifest_entrypoints(names, type: :typescript), type: type, **options)
  end

  # Public: Renders a <link> tag for the specified Vite entrypoints.
  def vite_stylesheet_tag(*names, **options)
    stylesheet_link_tag(*sources_from_vite_manifest_entrypoints(names, type: :stylesheet), **options)
  end

private

  def sources_from_vite_manifest_entrypoints(names, type:)
    names.flat_map { |name| vite_asset_path(name, type: type) }.uniq
  end
end
