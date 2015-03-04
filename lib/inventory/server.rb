require 'middleware'
require "inventory/server/version"
require "inventory/server/loader"
require "inventory/server/config"
require "inventory/server/logger"

module Inventory
  module Server
    class Server
      attr_reader :config, :middlewares

      def initialize(cli_config)
        config = Config.generate(cli_config)
        @config = config

        InventoryLogger.setup(config[:logger])
        InventoryLogger.logger.level = config[:log_level]

        # Dynamically load plugins from plugins_path
        plugin_names = config[:plugins]
        @middlewares = Middleware::Builder.new do
          plugins = Loader.new(config).load_plugins(*plugin_names)
          plugins.each {|klass|
            use klass, config
          }
        end
      end
    end
  end
end
