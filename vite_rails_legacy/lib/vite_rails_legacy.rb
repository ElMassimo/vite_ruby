# frozen_string_literal: true

require "vite_ruby"

require "vite_rails_legacy/version"
require "vite_rails_legacy/config"
require "vite_rails_legacy/tag_helpers"
require "vite_rails_legacy/engine" if defined?(Rails)

# Active Support 4 does not support multiple arguments in append.
class Array
  alias_method :append, :push
end
