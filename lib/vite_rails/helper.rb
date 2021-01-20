# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module ViteRails::Helper
  DEFAULT_VITE_SKIP_PRELOAD_TAGS = Rails::VERSION::MAJOR <= 5 && Rails::VERSION::MINOR < 2

  # Public: Returns the current Vite Rails instance.
  def current_vite_instance
    ViteRails.instance
  end

  # Public: Computes the relative path for the specified given Vite asset.
  #
  # Example:
  #   <%= vite_asset_path 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
  def vite_asset_path(name, **options)
    current_vite_instance.manifest.lookup!(name, **options).fetch('file')
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
    js_tags = javascript_include_tag(*js_entries.map { |entry| entry['file'] }, type: type, crossorigin: crossorigin, **options)

    unless skip_preload_tags || ViteRails.dev_server.running?
      preload_paths = js_entries.flat_map { |entry| entry['imports'] }.compact.uniq
      preload_tags = preload_paths.map { |path| preload_link_tag(path, crossorigin: crossorigin) }
    end

    unless skip_style_tags || ViteRails.dev_server.running?
      style_paths = names.map { |name| current_vite_instance.manifest.lookup(name, type: :stylesheet)&.fetch('file') }.compact
      style_tags = stylesheet_link_tag(*style_paths)
    end

    safe_join [js_tags, preload_tags, style_tags]
  rescue => error
    (require 'pry-byebug';binding.pry;);
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  #
  # NOTE: Because TypeScript is not a valid target in browsers, we only specify
  # the ts file when running the Vite development server.
  def vite_typescript_tag(*names, **options)
    vite_javascript_tag(*names, asset_type: :typescript, **options)
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
