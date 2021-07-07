# frozen_string_literal: true

module Administrator
  module ApplicationHelper
    # Override: Returns the engine assets manifest.
    def vite_manifest
      Administrator::Engine.vite_ruby.manifest
    end
  end
end
