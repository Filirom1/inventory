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
      def initialize(app, config)
        @app = app
        @config = config
      end

      def call(env)
        Filum.logger.info "Index"

        # Index it into elasticsearch
        id = env[:id]
        facts = env[:facts]
        raise 'id is missing' if id.nil? || id.empty?
        raise 'facts is missing' if facts.nil? || facts.empty?

        type = facts[@config[:type_key]] || @config[:type_default]
        version = facts[@config[:version_key]] || @config[:version_default]

        begin
          response = RestClient.put("#{@config[:es_host]}/#{type}/#{version}/#{id}", facts.to_json)
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
