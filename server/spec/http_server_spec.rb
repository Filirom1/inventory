ENV['RACK_ENV'] = 'test'

require 'inventory/server/http_server'
require 'rspec'
require 'rack/test'


RSpec.describe Inventory::Server::HTTPServer do
  context "when doing POST on api/v1/facts/:id" do
    include Rack::Test::Methods

    executed = 0
    trigger_error = true

    middleware = lambda { |env|
      executed += 1
      raise 'my custom error message' if trigger_error
    }

    # Proc.new is needed because Sinatra use lambda for lazy loading
    Inventory::Server::HTTPServer.set :middlewares, Proc.new { middleware }
    Inventory::Server::HTTPServer.set :config, {}

    def app
      Inventory::Server::HTTPServer
    end

    before(:each) do
      executed = 0
      trigger_error = false
    end

    it "should do the processing" do
      post '/api/v1/facts/MY_UUID', {"key" => "value"}
      expect(last_response).to be_ok
      expect(last_response.body).to eq('{"id":"MY_UUID","ok":true,"status":200}')
      expect(executed).to eq 1
    end

    it "should return error when processing fails" do
      trigger_error = true
      post '/api/v1/facts/MY_UUID', {"key" => "value"}
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 500
      expect(last_response.body).to eq('{"id":"MY_UUID","ok":false,"status":500,"message":"my custom error message"}')
      expect(executed).to eq 1
    end

    it "should return 404 without id" do
      trigger_error = true
      post '/api/v1/facts/', {"key" => "value"}
      expect(last_response).to_not be_ok
      expect(last_response.status).to eq 404
      expect(last_response.body).to eq('{"id":null,"ok":false,"status":404,"message":"Sinatra::NotFound"}')
      expect(executed).to eq 0
    end
  end
end
