# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module ViteHanami::TagHelpers
  # Public: Renders a script tag for vite/client to enable HMR in development.
  def vite_client
    return unless src = vite_manifest.vite_client_src

    html.script(src: src, type: "module")
  end

  # Public: Renders a script tag to enable HMR with React Refresh.
  def vite_react_refresh
    tag = vite_manifest.react_refresh_preamble
    raw(tag) if tag
  end

  # Public: Resolves the path for the specified Vite asset.
  #
  # Example:
  #   <%= vite_asset_path 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
  def vite_asset_path(name, **options)
    asset_path vite_manifest.path_for(name, **options)
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  def vite_javascript(*names,
    type: "module",
    asset_type: :javascript,
    skip_preload_tags: false,
    skip_style_tags: false,
    crossorigin: "anonymous",
    **options)
    entries = vite_manifest.resolve_entries(*names, type: asset_type)
    tags = javascript(*entries.fetch(:scripts), crossorigin: crossorigin, type: type, **options)
    tags << vite_modulepreload(*entries.fetch(:imports), crossorigin: crossorigin) unless skip_preload_tags
    tags << stylesheet(*entries.fetch(:stylesheets)) unless skip_style_tags
    ::Hanami::Utils::Escape::SafeString.new(tags)
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  def vite_typescript(*names, **options)
    vite_javascript(*names, asset_type: :typescript, **options)
  end

  # Public: Renders a <link> tag for the specified Vite entrypoints.
  def vite_stylesheet(*names, **options)
    style_paths = names.map { |name| vite_asset_path(name, type: :stylesheet) }
    stylesheet(*style_paths, **options)
  end

private

  # Internal: Returns the current manifest loaded by Vite Ruby.
  def vite_manifest
    ViteRuby.instance.manifest
  end

  # Internal: The leading path to every Vite asset.
  def vite_assets_prefix
    "/#{ViteRuby.instance.config.public_output_dir}"
  end

  # Internal: Renders a modulepreload link tag.
  def vite_modulepreload(*sources, crossorigin:)
    _safe_tags(*sources) { |source|
      href = asset_path(source)
      _push_promise(href, as: :script)
      html.link(rel: "modulepreload", href: href, as: :script, crossorigin: crossorigin)
    }
  end

  # Override: Hanami doesn't play nice with non-managed assets, it will always
  # prefix them and there's no configuration option to avoid it.
  def _relative_url(source)
    if self.class.assets_configuration.cdn || !source.to_s.start_with?(vite_assets_prefix)
      self.class.assets_configuration.asset_path(source)
    else
      Hanami::Utils::PathPrefix.new("/").join(source).to_s
    end
  end
end
