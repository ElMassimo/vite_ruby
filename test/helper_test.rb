# frozen_string_literal: true

require 'test_helper'

class HelperTest < ActionView::TestCase
  include ViteRailsTestHelpers

  tests ViteRails::Helper

  attr_reader :request

  def setup
    @request = Class.new do
      def send_early_hints(links) end

      def base_url
        'https://example.com'
      end
    end.new
  end

  def test_vite_client_tag
    assert_nil vite_client_tag
    with_dev_server_running {
      assert_equal '<script src="/@vite/client" type="module"></script>', vite_client_tag
    }
  end

  def test_vite_asset_path
    assert_equal '/vite-production/assets/colored.1173bfe0.js', vite_asset_path('colored.js')
    assert_equal '/vite-production/assets/colored.84277fd6.css', vite_asset_path('colored.css')
    with_dev_server_running {
      assert_equal '/vite-production/colored.js', vite_asset_path('colored.js')
      assert_equal '/vite-production/colored.css', vite_asset_path('colored.css')
    }
  end

  def test_vite_stylesheet_tag
    assert_equal %(<link rel="stylesheet" media="screen" href="/vite-production/assets/colored.84277fd6.css" />),
      vite_stylesheet_tag('colored')

    assert_equal vite_stylesheet_tag('colored'), vite_stylesheet_tag('colored.css')

    with_dev_server_running {
      assert_equal %(<link rel="stylesheet" media="screen" href="/vite-production/colored.css" />),
        vite_stylesheet_tag('colored')

      assert_equal vite_stylesheet_tag('colored'), vite_stylesheet_tag('colored.css')
    }
  end

  def test_vite_javascript_tag
    assert_equal [
      %(<script src="/vite-production/assets/application.a0ba047e.js" crossorigin="anonymous" type="module"></script>),
      %(<link rel="preload" href="/vite-production/assets/example_import.8e1fddc0.js" as="script" type="text/javascript" crossorigin="anonymous">),
      %(<link rel="stylesheet" media="screen" href="/vite-production/assets/application.cccfef34.css" />),
    ].join, vite_javascript_tag('application')

    assert_equal vite_javascript_tag('application'), vite_javascript_tag('application.js')
    assert_equal vite_javascript_tag('application'), vite_typescript_tag('application')

    with_dev_server_running {
      assert_equal %(<script src="/vite-production/application.js" crossorigin="anonymous" type="module"></script>),
        vite_javascript_tag('application')

      assert_equal %(<script src="/vite-production/application.ts" crossorigin="anonymous" type="module"></script>),
        vite_typescript_tag('application')
    }
  end
end
