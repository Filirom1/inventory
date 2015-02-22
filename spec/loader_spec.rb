require 'inventory/server/loader'

require "filum"

Filum.setup '/dev/null'

RSpec.describe Inventory::Server::Loader do

  context "without plugin_path" do
    loader = Inventory::Server::Loader.new(Inventory::Server::Config::DEFAULTS)

    it "should throw an error when loading non existing plugins" do
      expect {
        plugins = loader.load_plugins 'blabla'
      }.to raise_error 'Plugin blabla not found'
    end

    it "should load official plugins" do
      plugins = loader.load_plugins 'index', 'facts_parser'
      expect(plugins[0]).to eq Inventory::Server::Index
      expect(plugins[1]).to eq Inventory::Server::FactsParser
    end
  end

  context "with an existing plugin_path" do
    loader = Inventory::Server::Loader.new(:plugins_path => File.join(File.dirname(__FILE__), 'fixtures'))
    it "should load custom plugins" do
      plugins = loader.load_plugins 'simple_plugin'
      expect(plugins[0]).to eq Inventory::Server::SimplePlugin
    end

    it "should throw an error if plugins_path not found" do
      expect {
        loader = Inventory::Server::Loader.new(:plugins_path => '/tmp/blabla/plugins')
      }.to raise_error 'plugins_path /tmp/blabla/plugins not found'
    end
  end
end
