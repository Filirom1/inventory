require 'inventory/server/inventory_error'
require "inventory/server/logger"

module Inventory
  module Server
    class Sample
      def initialize(app, config)
        @app = app
        @config = config
      end

      def call(env)
        InventoryLogger.logger.info "Sample"

        # Index it into elasticsearch
        id = env[:id]
        raise InventoryError.new 'id is missing' if id.nil? || id.empty?

        # TODO

        @app.call(env)
      end
    end
  end
end
