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
      end

      post "/api/v1/facts/:id" do
        content_type :json
        id= params[:id]
        Filum.logger.context_id = id

        settings.middlewares.call(:id => id, :body => request.body.read, :config => settings.config)
        {:id => id, :ok => true}.to_json
      end
    end
  end
end
