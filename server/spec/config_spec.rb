require 'inventory/server/config'

require "filum"

Filum.setup '/dev/null'

RSpec.describe Inventory::Server::Config do
  context "without configuration" do
    it "should should use default configuration" do
      config = Inventory::Server::Config.new({})
      expect(config[:smtp_port]).to eq 2525
    end
  end


  context "with ENV configuration" do
    before do
      ENV['INVENTORY_HOST'] = "127.0.0.1"
      ENV['INVENTORY_SMTP_PORT'] = "2626"
      ENV['INVENTORY_DEBUG'] = "false"
      ENV['INVENTORY_LOGGER'] = "stdout"
      ENV['INVENTORY_LOG_LEVEL'] = "DEBUG"
    end

    after do
      ENV['INVENTORY_HOST'] = nil
      ENV['INVENTORY_SMTP_PORT'] = nil
      ENV['INVENTORY_DEBUG'] = nil
      ENV['INVENTORY_LOGGER'] = nil
      ENV['INVENTORY_LOG_LEVEL'] = nil
    end

    it "should use the ENV configuration" do
      config = Inventory::Server::Config.new({})
      expect(config[:host]).to eq '127.0.0.1'
    end

    it "should should cast integer" do
      config = Inventory::Server::Config.new({})
      expect(config[:smtp_port]).to eq 2626
    end

    it "should should cast boolean" do
      config = Inventory::Server::Config.new({})
      expect(config[:debug]).to eq false
    end

    it "should should cast stdout/stderr" do
      config = Inventory::Server::Config.new({})
      expect(config[:logger]).to eq $stdout
    end

    it "should should cast DEBUG/INFO/WARN/ERROR/FATAL" do
      config = Inventory::Server::Config.new({})
      expect(config[:log_level]).to eq Logger::DEBUG
    end

    context "with CLI configuration" do
      it "should use the CLI configuration" do
        config = Inventory::Server::Config.new({:smtp_port => 25})
        expect(config[:smtp_port]).to eq 25
      end
    end
  end
end