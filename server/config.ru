require 'filum'
require 'inventory/server'

module Inventory
  module Server
    server = Server.new({})
    HTTPServer.set :port, server.config[:http_port]
    HTTPServer.run!
  end
end
