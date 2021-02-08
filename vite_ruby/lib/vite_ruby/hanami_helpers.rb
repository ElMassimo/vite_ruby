# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module ViteRuby::HanamiHelpers
  # Public: Returns the current ViteRuby instance.
  def current_vite_instance
    ViteRuby.instance
  end

  # Public: Renders a script tag for vite/client to enable HMR in development.
  def vite_client
    return unless current_vite_instance.dev_server_running?

    html.script(src: current_vite_instance.manifest.prefix_vite_asset('@vite/client'), type: 'module')
  end

  # Public: Resolves the path for the specified Vite asset.
  #
  # Example:
  #   <%= vite_asset 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
  def vite_asset_path(name, **options)
    asset_path current_vite_instance.manifest.lookup!(name, **options).fetch('file')
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  def vite_javascript(*names,
                      type: 'module',
                      asset_type: :javascript,
                      skip_preload_tags: false,
                      skip_style_tags: false,
                      crossorigin: 'anonymous',
                      **options)
    js_entries = names.map { |name| current_vite_instance.manifest.lookup!(name, type: asset_type) }
    js_tags = js_entries.map { |entry| html.script(src: entry['file'], crossorigin: crossorigin, type: type, **options) }

    preload_entries = js_entries.flat_map { |entry| entry['imports'] }.compact.uniq

    unless skip_preload_tags || current_vite_instance.dev_server_running?
      preload_paths = preload_entries.map { |entry| entry['file'] }.compact.uniq
      preload_tags = preload_paths.map { |path| module_preload(href: path, crossorigin: crossorigin) }
    end

    unless skip_style_tags || current_vite_instance.dev_server_running?
      style_paths = (js_entries + preload_entries).flat_map { |entry| entry['css'] }.compact.uniq
      style_tags = style_paths.map { |href| html.link(rel: 'stylesheet', ref: href) }
    end

    raw [js_tags, preload_tags, style_tags].compact.flatten.join("\n")
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  #
  # NOTE: Because TypeScript is not a valid target in browsers, we only specify
  # the ts file when running the Vite development server.
  def vite_typescript(*names, **options)
    raw vite_javascript(*names, asset_type: :typescript, extname: false, **options)
  end

  # Public: Renders a <link> tag for the specified Vite entrypoints.
  def vite_stylesheet(*names, **options)
    raw sources_from_vite_manifest(names, type: :stylesheet).map { |name|
      html.link(rel: 'stylesheet', href: name, **options)
    }.join("\n")
  end

private

  def sources_from_vite_manifest(names, type:)
    names.map { |name| vite_asset_path(name, type: type) }
  end

  def module_preload(href:, crossorigin:)
    html.link(rel: 'modulepreload', href: href, as: 'script', crossorigin: crossorigin)
  end
end
