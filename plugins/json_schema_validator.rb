require 'json-schema'
require 'inventory/server/inventory_error'
require "inventory/server/logger"

module Inventory
  module Server
    class JsonSchemaValidator
      def initialize(app, config)
        @app = app
        @config = config
      end

      def call(env)
        InventoryLogger.logger.info "JSON Schema Validator"
        facts = env[:facts]
        raise InventoryError.new 'facts is missing' if facts.nil? || facts.empty?

        type = facts[@config[:type_key]] || @config[:type_default]
        version = facts[@config[:version_key]] || @config[:version_default]

        json_schema_file = File.join @config[:json_schema_dir], type, "#{version}.json"

        if ! File.file? json_schema_file
          InventoryLogger.logger.info "No JSON Schema found at #{json_schema_file}, skip validation"
          return @app.call(env)
        end

        InventoryLogger.logger.info "Use JSON Schema #{json_schema_file}"
        JSON::Validator.validate!(json_schema_file, facts)
      end
    end
  end
end
