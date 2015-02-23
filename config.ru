require 'sinatra'
require 'inventory/server'
require 'inventory/server/http_server'

server = Inventory::Server::Server.new({})
Inventory::Server::HTTPServer.set :config, server.config
Inventory::Server::HTTPServer.set :middlewares, server.middlewares
run Inventory::Server::HTTPServer
