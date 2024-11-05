# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module VitePadrino::TagHelpers
  # Public: Renders a script tag for vite/client to enable HMR in development.
  def vite_client_tag
    return unless src = vite_manifest.vite_client_src

    content_tag(:script, nil, src: src, type: "module")
  end

  # Public: Renders a script tag to enable HMR with React Refresh.
  def vite_react_refresh_tag
    vite_manifest.react_refresh_preamble&.html_safe
  end

  # Public: Resolves the path for the specified Vite asset.
  #
  # Example:
  #   <%= vite_asset_path 'calendar.css' %> # => "/vite/assets/calendar-1016838bab065ae1e122.css"
  def vite_asset_path(name, **options)
    asset_path vite_manifest.path_for(name, **options)
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  def vite_javascript_tag(*names,
    type: "module",
    asset_type: :javascript,
    skip_preload_tags: false,
    skip_style_tags: false,
    crossorigin: "anonymous",
    **options)
    entries = vite_manifest.resolve_entries(*names, type: asset_type)
    tags = javascript_include_tag(*entries.fetch(:scripts), crossorigin: crossorigin, type: type, extname: false, **options)
    tags << vite_preload_tag(*entries.fetch(:imports), crossorigin: crossorigin) unless skip_preload_tags
    tags << stylesheet_link_tag(*entries.fetch(:stylesheets)) unless skip_style_tags
    tags
  end

  # Public: Renders a <script> tag for the specified Vite entrypoints.
  def vite_typescript_tag(*names, **options)
    vite_javascript_tag(*names, asset_type: :typescript, **options)
  end

  # Public: Renders a <link> tag for the specified Vite entrypoints.
  def vite_stylesheet_tag(*names, **options)
    style_paths = names.map { |name| vite_asset_path(name, type: :stylesheet) }
    stylesheet_link_tag(*style_paths, **options)
  end

private

  # Internal: Returns the current manifest loaded by Vite Ruby.
  def vite_manifest
    ViteRuby.instance.manifest
  end

  # Internal: Renders a modulepreload link tag.
  def vite_preload_tag(*sources, crossorigin:)
    sources.map { |source|
      href = asset_path(source)
      try(:request).try(:send_early_hints, "Link" => %(<#{href}>; rel=modulepreload; as=script; crossorigin=#{crossorigin}))
      tag(:link, rel: "modulepreload", href: href, as: "script", crossorigin: crossorigin)
    }.join("\n").html_safe
  end
end
