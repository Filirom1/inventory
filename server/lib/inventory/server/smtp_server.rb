require "rubygems"
require "midi-smtp-server"
require 'filum'
require "inventory/server/email_parser"

module Inventory
  module Server

    # Create an SMTP Server
    class SMTPServer < MidiSmtpServer

      def initialize(config, middleware)
        @config = config
        @middleware = middleware
        @audit = @config[:debug]
        super(config[:smtp_port], config[:host], config[:max_connections])
      end

      def on_message_data_event(ctx)
        begin 
          # execute middlewares
          id, body = EmailParser.parse(ctx[:message])
          Filum.logger.context_id = id
          @middleware.call(:id => id, :body => body)
        rescue => e
          Filum.logger.error $!
          Filum.logger.error "#{e.backtrace.join("\n\t")}"

          # dot not raise the error to avoid the SMTP server relay to defer malformed emails
        end
      end

      def log(msg)
        Filum.logger.debug msg
      end
    end
  end
end
