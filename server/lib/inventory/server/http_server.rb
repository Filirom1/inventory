require 'sinatra'
require 'json'

module Inventory
  module Server
    class HTTPServer < Sinatra::Base

      configure do
        rack_logger = Object.new.tap do |proxy|
          def proxy.<<(message)
            Filum.logger.info message
          end
        end

        use Rack::CommonLogger, rack_logger

        Rack::Utils.key_space_limit = 262144 

        HTTPServer.set :raise_errors, false
        HTTPServer.set :dump_errors, false
      end

      post "/api/v1/facts/:id" do
        content_type :json
        id= params[:id]
        env[:id] = id
        Filum.logger.context_id = id

        settings.middlewares.call(:id => id, :body => request.body.read, :config => settings.config)
        {:id => id, :ok => true, :status => 200}.to_json
      end

      error 400..500 do
        {:id => env[:id], :ok => false, :status => status, :message => env['sinatra.error']}.to_json
      end
    end
  end
end
