require 'inventory/server/inventory_error'
require "inventory/server/logger"

require 'rest-client'

module Inventory
  module Server
    class LogFailuresInEs
      def initialize(app, config)
        @app = app
        @failed_facts_dir = config[:failed_facts_dir]
        @config = config
      end

      def call(env)
        id = env[:id]
        raise InventoryError.new 'id missing' if id.nil? || id.empty?

        body = env[:body]
        raise InventoryError.new "body missing" if body.nil? || body.empty?

        url = "#{@config[:es_host]}/#{@config[:es_failure_index]}/#{@config[:es_failure_type]}/#{id}"
        begin
          result = @app.call(env)
          RestClient.delete(url) rescue result
          return result
        rescue => e
          InventoryLogger.logger.error $!
          InventoryLogger.logger.error "#{e.backtrace}"
          InventoryLogger.logger.error "Failed facts stored on #{url}"
    
          env['error_message'] = $!
          env['stack_trace'] = "#{e.backtrace}"

          begin
            RestClient.put(url, env.to_json) 
          rescue => e
            InventoryLogger.logger.error "Fail to store failed facts #{e}: #{e.response}"
            raise e
          end

          raise e
        end
      end
    end
  end
end
