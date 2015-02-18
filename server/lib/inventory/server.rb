require 'filum'
require 'middleware'
require "inventory/server/version"
require "inventory/server/config"
require "inventory/server/facts_parser"
require "inventory/server/index"

module Inventory
  module Server
    class Server
      attr_reader :config, :middleware

      def initialize(cli_config)
        @config = Config.new(cli_config)

        Filum.setup(@config[:logger])
        Filum.logger.level = @config[:log_level]

        @middleware = Middleware::Builder.new do
          use FactsParser
          use Index
          #use WebHooks
        end
      end
    end
  end
end
