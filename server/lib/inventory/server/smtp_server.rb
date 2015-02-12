require "rubygems"
require "midi-smtp-server"
require 'filum'

module Inventory
  module Server

    # Create an SMTP Server
    class SMTPServer < MidiSmtpServer

      def initialize(config)
        @config = config
        super(config[:port], config[:host], config[:maxConnections])
      end

      def on_message_data_event(ctx)
        begin 
          # execute middlewares
          @config[:middleware].call(:ctx => ctx)
        rescue => e
          Filum.logger.error $!
          Filum.logger.error "#{e.backtrace.join("\n\t")}"
          raise e
        end
      end

      def log(msg)
        if @stdlog
          Filum.logger.debug msg
        end
      end
    end
  end
end
