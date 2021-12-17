# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module VitePluginLegacy::TagHelpers
  # Public: Renders a <script> tag for the specified Vite entrypoints when using
  # @vitejs/plugin-legacy, which injects polyfills.
  def vite_legacy_javascript_tag(name, asset_type: :javascript)
    return if ViteRuby.instance.dev_server_running?

    legacy_name = name.sub(/(\..+)|$/, '-legacy\1')
    import_tag = content_tag(:script, nomodule: true) {
      "System.import('#{ vite_asset_path(legacy_name, type: asset_type) }')".html_safe
    }

    safe_join [vite_legacy_polyfill_tag, import_tag]
  end

  # Public: Same as `vite_legacy_javascript_tag`, but for TypeScript entries.
  def vite_legacy_typescript_tag(name)
    vite_legacy_javascript_tag(name, asset_type: :typescript)
  end

  # Internal: Renders the vite-legacy-polyfill to enable code splitting in
  # browsers that do not support modules.
  def vite_legacy_polyfill_tag
    return if ViteRuby.instance.dev_server_running?

    content_tag(:script, nil, nomodule: true, src: vite_asset_path('legacy-polyfills', type: :virtual))
  end
end
