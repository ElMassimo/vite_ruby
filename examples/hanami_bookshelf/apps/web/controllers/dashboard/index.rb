require 'hanami/action/cache'

module Web
  module Controllers
    module Dashboard
      class Index
        include Web::Action
        include Hanami::Action::Cache

        cache_control :public, max_age: 600

        def call(params)
        end
      end
    end
  end
end
