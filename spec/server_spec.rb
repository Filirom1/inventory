require 'inventory/server.rb'

require "filum"

Filum.setup '/dev/null'

RSpec.describe Inventory::Server::Server do
  it "should instantiate without error" do
    expect(Filum).to_not receive(:setup).with(any_args).once
    server = Inventory::Server::Server.new({})

    expect(server.config).to_not eq nil
    expect(server.middlewares).to_not eq nil
  end
end
