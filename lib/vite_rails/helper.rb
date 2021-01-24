# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module ViteRails::Helper
  DEFAULT_VITE_SKIP_PRELOAD_TAGS = Rails.gem_version < Gem::Version.new('5.2.0')

  # Public: Returns the current Vite Rails instance.
  def current_vite_instance
    ViteRails.instance
  end

  # Public: Renders a script tag for vite/client to enable HMR in development.
  def vite_client_tag
    return unless current_vite_instance.dev_server_running?

    content_tag('script', '', src: current_vite_instance.config.public_output_dir.join('@vite/client'), type: 'module')
  end

  # Public: Resolves the path for the specified Vite asset.
  #
  # Example:
  #   <%= vite_asset_path 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
  def vite_asset_path(name, **options)
    path_to_asset current_vite_instance.manifest.lookup!(name, **options).fetch('file')
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  def vite_javascript_tag(*names,
                          type: 'module',
                          asset_type: :javascript,
                          skip_preload_tags: DEFAULT_VITE_SKIP_PRELOAD_TAGS,
                          skip_style_tags: false,
                          crossorigin: 'anonymous',
                          **options)
    js_entries = names.map { |name| current_vite_instance.manifest.lookup!(name, type: asset_type) }
    js_tags = javascript_include_tag(*js_entries.map { |entry| entry['file'] }, crossorigin: crossorigin, type: type, **options)

    unless skip_preload_tags || current_vite_instance.dev_server_running?
      preload_paths = js_entries.flat_map { |entry| entry['imports'] }.compact.uniq
      preload_tags = preload_paths.map { |path| preload_link_tag(path, crossorigin: crossorigin) }
    end

    unless skip_style_tags || current_vite_instance.dev_server_running?
      style_paths = names.map { |name|
        current_vite_instance.manifest.lookup(name.delete_suffix('.js'), type: :stylesheet)&.fetch('file')
      }.compact
      style_tags = stylesheet_link_tag(*style_paths)
    end

    safe_join [js_tags, preload_tags, style_tags]
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  #
  # NOTE: Because TypeScript is not a valid target in browsers, we only specify
  # the ts file when running the Vite development server.
  def vite_typescript_tag(*names, **options)
    vite_javascript_tag(*names, asset_type: :typescript, extname: false, **options)
  end

  # Public: Renders a <link> tag for the specified Vite entrypoints.
  def vite_stylesheet_tag(*names, **options)
    stylesheet_link_tag(*sources_from_vite_manifest(names, type: :stylesheet), **options)
  end

private

  def sources_from_vite_manifest(names, type:)
    names.map { |name| vite_asset_path(name, type: type) }
  end
end
