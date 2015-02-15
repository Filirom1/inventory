require "mail"
require "filum"

module Inventory
  module Server
    class EmailParser
      def initialize(app)
        @app = app
      end

      def call(env)
        parse(env)
        @app.call(env)
      end

      def parse(env)
        Filum.logger.info "Email parser"
        ctx = env[:ctx]
        raise "ctx missing" if !ctx
        raise "ctx message missing" if !ctx[:message]

        # Parse the email
        email = Mail.read_from_string(ctx[:message])

        # Use email subject as an ID
        email_subject = email.subject
        raise "email subject is missing" if email_subject.nil? || email_subject.empty?
        Filum.logger.context_id = email_subject
        env[:id] = email_subject

        # Decode the email body
        email_body = email.body.decoded
        raise "email body is missing" if email_body.nil? || email_body.empty?
        env[:body] = email_body
      end
    end
  end
end
