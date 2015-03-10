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
        raise InventoryError.new 'facts is missing' if facts.nil?

        type = facts[@config[:type_key]] || @config[:type_default]
        version = facts[@config[:version_key]] || @config[:version_default]

        url = clean_string "#{@config[:es_host]}/#{@config[:es_index_prefix]}#{type}/#{version}/#{id}"

        begin
          response = RestClient.put(url, facts.to_json)
          InventoryLogger.logger.info response
        rescue => e
          if e.respond_to?(:response)
            raise InventoryError.new "#{e}: #{e.response}"
          else
            raise e
          end
        end
        @app.call(env)
        facts
      end

      private

      def clean_string(str)
        str.gsub('.', '-').gsub(' ', '_').encode(Encoding.find('ASCII'), :invalid => :replace, :undef => :replace, :replace => '')
      end
    end
  end
end
