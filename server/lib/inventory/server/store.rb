require 'rest-client'
require 'json'
require 'filum'

BASE_URL="http://localhost:9200/"
TYPE="inventory"

# Forward RestClient logs to Filum
RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      Filum.logger.debug message
    end
  end

module Inventory
  module Server
    class Store
      def initialize(app)
        @app = app
      end

      def call(env)
        Filum.logger.info "Store"

        # Index it into elasticsearch
        facts = env[:facts]
        version = facts['version'] || '1.0.0'
        response = RestClient.put("#{BASE_URL}/#{TYPE}-#{version}/#{TYPE}/#{env[:id]}", facts.to_json)

        Filum.logger.info response
        @app.call(env)
      end
    end
  end
end
