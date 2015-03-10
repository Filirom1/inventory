require 'sinatra'
require 'json'
require 'inventory/server/inventory_error'
require "inventory/server/logger"

module Inventory
  module Server
    class HTTPServer < Sinatra::Base

      configure do
        logger = Object.new.tap do |proxy|
          def proxy.<<(message)
            InventoryLogger.logger.info message
          end
          def proxy.write(message)
            InventoryLogger.logger.info message
          end
          def proxy.flush; end
        end

        use Rack::CommonLogger, logger

        before {
          env["rack.errors"] = logger
        }

        Rack::Utils.key_space_limit = 262144 

        HTTPServer.set :raise_errors, false
        HTTPServer.set :dump_errors, false
      end

      post "/api/v1/facts/:id" do
        content_type :json
        id= params[:id]
        env[:id] = id
        InventoryLogger.logger.context_id = id

        request.body.rewind
        result = settings.middlewares.call({ :id => id, :body => request.body.read, :config => settings.config })
        return {:id => id}.merge!(result).to_json
      end

      error 400..500 do
        {:id => env[:id], :message => env['sinatra.error']}.to_json
      end
    end
  end
end
