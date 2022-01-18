require_relative "lib/administrator/version"

Gem::Specification.new do |spec|
  spec.name        = "administrator"
  spec.version     = Administrator::VERSION
  spec.authors     = ["Maximo Mussini"]
  spec.email       = ["maximomussini@gmail.com"]
  spec.homepage    = "https://github.com/ElMassimo/vite_ruby/tree/main/examples/example_engine"
  spec.summary     = "Example of how to use Vite Ruby inside a Rails engine"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails"
  spec.add_dependency "vite_rails"
  spec.add_dependency "bootsnap"
end
