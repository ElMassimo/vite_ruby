# frozen_string_literal: true

require 'rails/railtie'

class ViteRails::Engine < Rails::Engine
  initializer 'vite_rails.proxy' do |app|
    app.middleware.insert_before 0, ViteRails::DevServerProxy, ssl_verify_none: true if ViteRails.run_proxy?
  end

  initializer 'vite_rails.helper' do
    ActiveSupport.on_load(:action_controller) do
      ActionController::Base.helper(ViteRails::Helper)
    end

    ActiveSupport.on_load(:action_view) do
      include ViteRails::Helper
    end
  end

  initializer 'vite_rails.logger' do
    config.after_initialize do
      ViteRails.logger = if ::Rails.logger.respond_to?(:tagged)
                           ::Rails.logger
                         else
                           ActiveSupport::TaggedLogging.new(::Rails.logger)
                         end
    end
  end

  initializer 'vite_rails.bootstrap' do
    if defined?(Rails::Server) || defined?(Rails::Console)
      ViteRails.bootstrap
      if defined?(Spring)
        require 'spring/watcher'
        Spring.after_fork { ViteRails.bootstrap }
        Spring.watch(ViteRails.config.config_path)
      end
    end
  end
end
