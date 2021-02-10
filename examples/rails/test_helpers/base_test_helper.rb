# frozen_string_literal: true

class BaseTestHelper < Capybara::TestHelper
# Aliases: Semantic aliases for locators, can be used in most DSL methods.
  aliases(
    # Avoid defining :el here since it will be inherited by all helpers.
  )

# Finders: A convenient way to get related data or nested elements.

# Actions: Encapsulate complex actions to provide a cleaner interface.

# Assertions: Check on element properties, used with `should` and `should_not`.

# Background: Helpers to add/modify/delete data in the database or session.
end
