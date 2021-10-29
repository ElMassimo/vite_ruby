# frozen_string_literal: true

# Internal: Provides access to every Rails route defined in the app.
class Urls
  include Rails.application.routes.url_helpers

  def default_url_options
    ActionMailer::Base.default_url_options
  end
end
