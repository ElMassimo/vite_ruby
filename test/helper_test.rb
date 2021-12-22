# frozen_string_literal: true

require 'test_helper'

require 'vite_plugin_legacy'

class HelperTestCase < ActionView::TestCase
  include ViteRubyTestHelpers

  attr_reader :request

  def setup
    super
    @request = Class.new do
      def send_early_hints(links) end

      def base_url
        'https://example.com'
      end
    end.new
  end

protected

  def link(href:, rel: 'stylesheet', media: 'screen', crossorigin: nil)
    attrs = [%(media="#{ media }"), %(href="#{ href }"), (%(crossorigin="#{ crossorigin }") if crossorigin)].compact
    attrs[1], attrs[2] = attrs[2], attrs[1] if Rails.gem_version > Gem::Version.new('6.1') && Rails.gem_version < Gem::Version.new('6.2') && attrs[2]
    attrs.reverse! if Rails.gem_version > Gem::Version.new('6.2')
    %(<link rel="#{ rel }" #{ attrs.join(' ') } />)
  end

  def assert_similar(*args)
    assert_equal(*args.map { |str|
      return str.tr("\n", '').gsub('" />', '">').gsub('"/>', '">') if RUBY_VERSION.start_with?('2.4')

      str.tr("\n", '')
    })
  end

  def with_dev_server_running(&block)
    refresh_config(mode: 'development')
    super(&block)
  end
end

class LegacyHelperTest < HelperTestCase
  tests(Module.new {
    include ViteRails::TagHelpers
    include VitePluginLegacy::TagHelpers
  })

  def test_plugin_legacy
    assert_includes vite_legacy_javascript_tag('/app/assets/external'), '/vite-production/assets/external.a35ee0db-legacy.js'
    assert_includes vite_legacy_typescript_tag('main.ts'), '/vite-production/assets/main.20bbd3a5-legacy.js'
    assert_includes vite_legacy_polyfill_tag, '/vite-production/assets/polyfills-legacy.07477394.js'
  end
end

class HelperTest < HelperTestCase
  tests ViteRails::TagHelpers

  def test_vite_client_tag
    assert_nil vite_client_tag
    with_dev_server_running {
      assert_equal '<script src="/vite-dev/@vite/client" type="module"></script>', vite_client_tag
    }
  end

  def test_vite_asset_path
    assert_equal '/vite-production/assets/main.9dcad042.js', vite_asset_path('main.ts')
    assert_equal '/vite-production/assets/app.517bf154.css', vite_asset_path('app.css')
    assert_equal '/vite-production/assets/logo.322aae0c.svg', vite_asset_path('images/logo.svg')
    assert_equal '/vite-production/assets/theme.e6d9734b.css', vite_asset_path('/app/assets/theme.css')
    with_dev_server_running {
      assert_equal '/vite-dev/entrypoints/main.ts', vite_asset_path('main.ts')
      assert_equal '/vite-dev/entrypoints/app.css', vite_asset_path('app.css')
      assert_equal '/vite-dev/images/logo.png', vite_asset_path('images/logo.png')
    }
  end

  def test_vite_stylesheet_tag
    assert_similar link(href: '/vite-production/assets/app.517bf154.css'), vite_stylesheet_tag('app')
    assert_equal vite_stylesheet_tag('app'), vite_stylesheet_tag('app.css')
    assert_similar link(href: '/vite-production/assets/sassy.3560956f.css'), vite_stylesheet_tag('sassy.scss')

    with_dev_server_running {
      assert_similar link(href: '/vite-dev/entrypoints/app.css'), vite_stylesheet_tag('app')
      assert_equal vite_stylesheet_tag('app'), vite_stylesheet_tag('app.css')
      assert_similar link(href: '/vite-dev/entrypoints/sassy.scss.css'), vite_stylesheet_tag('sassy.scss')
    }
  end

  def test_vite_javascript_tag
    assert_similar [
      %(<script src="/vite-production/assets/main.9dcad042.js" crossorigin="anonymous" type="module"></script>),
      %(<link rel="modulepreload" href="/vite-production/assets/log.818edfb8.js" as="script" crossorigin="anonymous">),
      %(<link rel="modulepreload" href="/vite-production/assets/vue.3002ada6.js" as="script" crossorigin="anonymous">),
      %(<link rel="modulepreload" href="/vite-production/assets/vendor.0f7c0ec3.js" as="script" crossorigin="anonymous">),
      link(href: '/vite-production/assets/app.517bf154.css', crossorigin: 'anonymous'),
      link(href: '/vite-production/assets/theme.e6d9734b.css', crossorigin: 'anonymous'),
      link(href: '/vite-production/assets/vue.ec0a97cc.css', crossorigin: 'anonymous'),
    ].join, vite_typescript_tag('main')

    assert_equal vite_javascript_tag('main.ts'),
      vite_typescript_tag('main')

    assert_equal vite_javascript_tag('entrypoints/frameworks/vue'),
      vite_javascript_tag('~/entrypoints/frameworks/vue.js')

    with_dev_server_running {
      assert_equal %(<script src="/vite-dev/entrypoints/frameworks/vue.js" crossorigin="anonymous" type="module"></script>),
        vite_javascript_tag('entrypoints/frameworks/vue')

      assert_equal %(<script src="/vite-dev/entrypoints/main.ts" crossorigin="anonymous" type="module"></script>),
        vite_typescript_tag('main')
    }
  end

  def test_vite_react_refresh_tag
    assert_nil vite_react_refresh_tag
    with_dev_server_running {
      assert_equal <<~HTML, vite_react_refresh_tag
        <script type="module">
          import RefreshRuntime from '/vite-dev/@react-refresh'
          RefreshRuntime.injectIntoGlobalHook(window)
          window.$RefreshReg$ = () => {}
          window.$RefreshSig$ = () => (type) => type
          window.__vite_plugin_react_preamble_installed__ = true
        </script>
      HTML
    }
  end

  def test_vite_image_tag
    assert_equal %(<img class="test" src="/vite-production/images/tag.as8d7a98.jpg" />),
      vite_image_tag('images/tag.jpg', class: 'test')

    assert_equal %(<img srcset="/vite-production/images/tag-2x.bs8d7a77.jpg 2x" src="/vite-production/images/tag.as8d7a98.jpg" />),
      vite_image_tag('images/tag.jpg', srcset: { 'images/tag-2x.jpg' => '2x' })

    with_dev_server_running {
      assert_equal %(<img src="/vite-dev/images/tag.jpg" />), vite_image_tag('images/tag.jpg')

      assert_equal %(<img srcset="/vite-dev/images/tag-2x.jpg 2x" src="/vite-dev/images/tag.jpg" />),
        vite_image_tag('images/tag.jpg', srcset: { 'images/tag-2x.jpg' => '2x' })
    }
  end
end
