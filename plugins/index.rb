require 'rest-client'
require 'json'
require 'inventory/server/inventory_error'
require "inventory/server/logger"

# Forward RestClient logs to InventoryLogger
RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      Inventory::Server::InventoryLogger.logger.debug message
    end
  end

module Inventory
  module Server
    class Index
      def initialize(app, config)
        @app = app
        @config = config
      end

      def call(env)
        InventoryLogger.logger.info "Index"

        # Index it into elasticsearch
        id = env[:id]
        facts = env[:facts]
        raise InventoryError.new 'id is missing' if id.nil? || id.empty?
        raise InventoryError.new 'facts is missing' if facts.nil? || facts.empty?

        type = facts[@config[:type_key]] || @config[:type_default]
        version = facts[@config[:version_key]] || @config[:version_default]

        begin
          response = RestClient.put("#{@config[:es_host]}/#{type}/#{version}/#{id}", facts.to_json)
          InventoryLogger.logger.info response
        rescue => e
          if e.respond_to?(:response)
            raise InventoryError.new "#{e}: #{e.response}"
          else
            raise e
          end
        end
        @app.call(env)
      end
    end
  end
end
