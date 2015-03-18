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
        raise InventoryError.new 'facts is missing' if facts.nil?

        type = facts[@config[:type_key]] || @config[:type_default]
        version = facts[@config[:version_key]] || @config[:version_default]

        schema_type_file = File.join @config[:json_schema_dir], "#{type}.json"
        schema_version_file = File.join @config[:json_schema_dir], type.to_s, "#{version}.json"

        if File.file? schema_type_file
          InventoryLogger.logger.info "Use JSON Schema #{schema_type_file}"
          JSON::Validator.validate!(schema_type_file, facts)
        end

        if File.file? schema_version_file
          InventoryLogger.logger.info "Use JSON Schema #{schema_version_file}"
          JSON::Validator.validate!(schema_version_file, facts)
        end

        @app.call(env)
      end
    end
  end
end
