require 'filum'
require 'inventory/server'
require 'inventory/server/http_server'

module Inventory
  module Server
    server = Server.new({})
    HTTPServer.set :port, server.config[:http_port]
    HTTPServer.set :config, server.config
    HTTPServer.set :middlewares, server.middleware
    HTTPServer.run!
  end
end
