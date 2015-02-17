require "rubygems"
require "midi-smtp-server"
require 'filum'

module Inventory
  module Server

    # Create an SMTP Server
    class SMTPServer < MidiSmtpServer

      def initialize(config)
        @config = config
        super(config[:smtp_port], config[:host], config[:max_connections])
      end

      def on_message_data_event(ctx)
        begin 
          # execute middlewares
          @config[:middleware].call(:ctx => ctx, :config => @config)
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
