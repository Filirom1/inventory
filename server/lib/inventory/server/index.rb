require 'rest-client'
require 'json'
require 'filum'

# Forward RestClient logs to Filum
RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      Filum.logger.debug message
    end
  end

module Inventory
  module Server
    class Index
      def initialize(app)
        @app = app
      end

      def call(env)
        Filum.logger.info "Index"

        es_host = env[:es_host] || "http://localhost:9200/"

        # Index it into elasticsearch
        id = env[:id]
        facts = env[:facts]
        raise 'id is missing' if id.nil? || id.empty?
        raise 'facts is missing' if facts.nil? || facts.empty?

        type = facts['type'] || 'server'
        version = facts['version'] || '1.0.0'
        begin
          response = RestClient.put("#{es_host}/#{type}/#{version}/#{id}", facts.to_json)
          Filum.logger.info response
        rescue => e
          if e.respond_to?(:response)
            raise "#{e}: #{e.response}"
          else
            raise e
          end
        end
        @app.call(env)
      end
    end
  end
end
