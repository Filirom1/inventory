require 'inventory/server.rb'

RSpec.describe Inventory::Server::Server do
  it "should instantiate without error" do
    expect(Inventory::Server::InventoryLogger).to_not receive(:setup).with(any_args).once
    server = Inventory::Server::Server.new({})

    expect(server.config).to_not eq nil
    expect(server.middlewares).to_not eq nil
  end
end
