require 'inventory/server/inventory_error'
require "inventory/server/logger"

module Inventory
  module Server
    class LogFailuresOnDisk
      def initialize(app, config)
        @app = app
        @failed_facts_dir = config[:failed_facts_dir]
      end

      def call(env)
        id = env[:id]
        raise InventoryError.new 'id missing' if id.nil? || id.empty?

        body = env[:body]
        raise InventoryError.new "body missing" if body.nil? || body.empty?

        begin
          @app.call(env)
        rescue => e
          filepath = "#{@failed_facts_dir}/#{id}"
          InventoryLogger.logger.error $!
          InventoryLogger.logger.error "#{e.backtrace}"
          InventoryLogger.logger.error "Failed facts stored on #{filepath}"

          File.write(filepath, body)
          File.write("#{filepath}.log", "#{e}\n\n#{e.backtrace.join("\n")}\n\n#{env.to_yaml}")

          raise e
        end
      end
    end
  end
end
