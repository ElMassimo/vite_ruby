require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require_relative '../lib/hanami_bookshelf'
require_relative '../apps/web/application'

Hanami.configure do
  mount Web::Application, at: '/'

  model do
    ##
    # Database adapter
    #
    # Available options:
    #
    #  * SQL adapter
    #    adapter :sql, 'sqlite://db/hanami_bookshelf_development.sqlite3'
    #    adapter :sql, 'postgresql://localhost/hanami_bookshelf_development'
    #    adapter :sql, 'mysql://localhost/hanami_bookshelf_development'
    #
    adapter :sql, ENV.fetch('DATABASE_URL')

    ##
    # Migrations
    #
    migrations 'db/migrations'
    schema     'db/schema.sql'
  end

  mailer do
    root 'lib/hanami_bookshelf/mailers'

    # See https://guides.hanamirb.org/mailers/delivery
    delivery :test
  end

  environment :development do
    middleware.use(ViteRuby::DevServerProxy, ssl_verify_none: true) if ViteRuby.run_proxy?
    # See: https://guides.hanamirb.org/projects/logging
    logger level: :debug
  end

  environment :production do
    logger level: :info, formatter: :json, filter: []

    mailer do
      delivery :smtp, address: ENV.fetch('SMTP_HOST'), port: ENV.fetch('SMTP_PORT')
    end
  end
end
