# frozen_string_literal: true

def add_default_load_paths
  super
  add_load_path("test")
end

def test_paths
  Dir.glob("test/**/*_test.rb", base: @root).reject do |path|
    path.include?("/test_app/") || path.include?("/mounted_app/") || path.include?("/dummy/")
  end
end
