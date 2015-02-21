require 'filum'
require 'middleware'
require "inventory/server/version"
require "inventory/server/config"
require "inventory/server/log_failures_on_disk"
require "inventory/server/facts_parser"
require "inventory/server/json_schema_validator"
require "inventory/server/index"

module Inventory
  module Server
    class Server
      attr_reader :config, :middlewares

      def initialize(cli_config)
        config = Config.generate(cli_config)
        @config = config

        Filum.setup(config[:logger])
        Filum.logger.level = config[:log_level]

        @middlewares = Middleware::Builder.new do
          use LogFailuresOnDisk, config
          use FactsParser, config
          use JSONSchemaValidator, config
          use Index, config
          #use WebHooks
        end
      end
    end
  end
end
