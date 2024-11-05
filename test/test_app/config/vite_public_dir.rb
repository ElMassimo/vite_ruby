# frozen_string_literal: true

ViteRuby.configure(public_output_dir: "from_ruby")
ViteRuby.env["EXAMPLE_PATH"] = Gem.loaded_specs["rails"].full_gem_path
