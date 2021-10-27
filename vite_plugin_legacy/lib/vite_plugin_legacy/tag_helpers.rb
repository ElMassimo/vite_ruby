# frozen_string_literal: true

# Public: Allows to render HTML tags for scripts and styles processed by Vite.
module VitePluginLegacy::TagHelpers
  VITE_SAFARI_NOMODULE_FIX = <<-JS.html_safe.freeze
  !function(){var e=document,t=e.createElement("script");if(!("noModule"in t)&&"onbeforeload"in t){var n=!1;e.addEventListener("beforeload",(function(e){if(e.target===t)n=!0;else if(!e.target.hasAttribute("nomodule")||!n)return;console.log('preventing load',e.target);e.preventDefault()}),!0),t.type="module",t.src=".",e.head.appendChild(t),t.remove()}}();
  JS

  # Renders code to load vite entrypoints for legacy browsers:
  # * Safari NOMODULE fix for Safari 10, which supports modules but not `nomodule`
  # * vite-legacy-polyfill (System.import polyfill) for browsers that do not support modules @vitejs/plugin-legacy
  # * Dynamic import code for browsers that support modules, but not dynamic imports
  # This helper must be called before any other Vite import tags.
  # Accepts a hash with entrypoint names as keys and asset types (:javascript or :typescript) as values.
  def vite_legacy_javascript_tag(entrypoints)
    return if ViteRuby.instance.dev_server_running?

    tags = []
    safari_nomodule_fix = content_tag(:script, nil, nomodule: true) { VITE_SAFARI_NOMODULE_FIX }
    tags.push(safari_nomodule_fix)
    # for browsers which do not support modules at all
    legacy_polyfill = content_tag(:script, nil, nomodule: true, id: 'vite-legacy-polyfill', src: vite_asset_path('legacy-polyfills', type: :virtual))
    tags.push(legacy_polyfill)
    # for browsers which support modules, but don't support dynamic import
    legacy_fallback_tag = content_tag(:script, nil, type: 'module') do
      vite_dynamic_fallback_inline_code(entrypoints)
    end
    entrypoints.each do |name, asset_type|
      import_tag = content_tag(:script, nomodule: true) do
        vite_legacy_import_body(name, asset_type: asset_type)
      end
      tags.push(import_tag)
    end
    tags.push(legacy_fallback_tag)
    safe_join(tags, "\n")
  end

  def vite_dynamic_fallback_inline_code(entrypoints)
    load_body = entrypoints.map do |name, asset_type|
      vite_legacy_import_body(name, asset_type: asset_type)
    end
    load_body = safe_join(load_body, "\n")
    # rubocop:disable Layout/LineLength
    %{!function(){try{new Function("m","return import(m)")}catch(o){console.warn("vite: loading legacy build because dynamic import is unsupported, syntax error above should be ignored");var e=document.getElementById("vite-legacy-polyfill"),n=document.createElement("script");n.src=e.src,n.onload=function(){#{ load_body }},document.body.appendChild(n)}}();}.html_safe
    # rubocop:enable Layout/LineLength
  end

  def vite_legacy_import_body(name, asset_type: :javascript)
    "System.import('#{ vite_asset_path(vite_legacy_name(name), type: asset_type) }')".html_safe
  end

  def vite_legacy_name(name)
    name.sub(/(\..+)|$/, '-legacy\1')
  end
end
