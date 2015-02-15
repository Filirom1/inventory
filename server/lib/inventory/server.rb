require 'filum'
require 'middleware'
require "inventory/server/version"

module Inventory
  module Server
    autoload :Config,      'inventory/server/config'
    autoload :SMTPServer,  'inventory/server/smtp_server'
    autoload :EmailParser, 'inventory/server/email_parser'
    autoload :FactsParser, 'inventory/server/facts_parser'
    autoload :Index,       'inventory/server/index'

    class Server

      def initialize(config)
        @config = Config.new(config)
        Filum.setup(@config[:logger])
        Filum.logger.level = @config[:log_level]

        config[:middleware] = Middleware::Builder.new do
          use EmailParser
          use FactsParser
          use Index
          #use WebHooks
        end

        @smtp_server = SMTPServer.new(@config)
      end

      def start()
        Filum.logger.info "Server started, listening on #{@config[:host]}:#{@config[:smtp_port]}"
        @smtp_server.start
        @smtp_server.audit = @config[:debug]
        @smtp_server.join
      end

      # Stop the server garcefully
      def stop()
        Filum.logger.info "Server is shutting down gracefully"
        @smtp_server.shutdown()

        unless @smtp_server.connections == 0
          Filum.logger.info "Still #{@smtp_server.connections} connections, wait 1 seconds"
          sleep 1
        end

        @smtp_server.stop
      end
    end
  end
end
