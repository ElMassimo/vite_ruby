# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

ViteRuby.instance.logger = ActiveSupport::Logger.new($stdout)

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.disable_monkey_patching!
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_gems_from_backtrace 'spring', 'rspec-core', 'given_core', 'capybara', 'bootsnap', 'activesupport', 'selenium-webdriver'

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end

### Integration Tests ###

require 'capybara_test_helpers/rspec'
require Rails.root.join('test_helpers/base_test_helper')

RSpec.configure do |config|
  config.include(Module.new {
    def urls
      @urls ||= Urls.new
    end
  })
end

# Require supporting ruby files with custom matchers and macros, etc,
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
