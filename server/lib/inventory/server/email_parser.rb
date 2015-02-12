require "mail"
require "filum"

module Inventory
  module Server
    class EmailParser
      def initialize(app)
        @app = app
      end

      def call(env)
        Filum.logger.info "Email parser"
        ctx = env[:ctx]
        raise "ctx missing" if !ctx

        email = Mail.read_from_string(ctx[:message])
        id = email.subject
        Filum.logger.context_id = id

        env[:id] = id 
        env[:body] = email.body.decoded

        @app.call(env)
      end
    end
  end
end
