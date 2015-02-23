require "rubygems"
require "midi-smtp-server"
require "inventory/server/email_parser"
require 'inventory/server/inventory_error'
require "inventory/server/logger"

module Inventory
  module Server

    # Create an SMTP Server
    class SMTPServer < MidiSmtpServer

      def initialize(config, middlewares)
        @config = config
        @middlewares = middlewares
        @audit = @config[:debug]
        super(config[:smtp_port], config[:host], config[:max_connections])
      end

      def on_message_data_event(ctx)
        begin 
          # execute middlewares
          id, body = EmailParser.parse(ctx[:message])
          InventoryLogger.logger.context_id = id
          @middlewares.call(:id => id, :body => body)
        rescue => e
          # dot not raise the error to avoid the SMTP server relay to defer malformed emails
        end
      end

      def log(msg)
        InventoryLogger.logger.debug msg
      end
    end
  end
end
