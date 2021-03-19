# frozen_string_literal: true

# Internal: Raised when the Vite executable can not be found.
class ViteRuby::MissingExecutableError < ViteRuby::Error
  def initialize(error = nil)
    super <<~MSG
      ❌ The vite binary is not available. Have you installed Vite?

      :troubleshooting:
      #{ error }
    MSG
  end
end
