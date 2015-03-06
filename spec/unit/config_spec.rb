require 'inventory/server/config'

RSpec.describe Inventory::Server::Config do
  context "without configuration" do
    before do
      # remove env env configuration
      ENV.each{|key|
        next unless key.is_a? String and key.start_with? 'INVENTORY_'
        ENV[key] = nil
      }
      # avoid mkdir exception
      expect(FileUtils).to receive(:mkdir_p).with(any_args)
    end

    it "should should use default configuration" do
      config = Inventory::Server::Config.generate({})
      expect(config[:smtp_port]).to eq 2525
    end
  end

  context "with etc configuration" do
    before do
      ENV['INVENTORY_FAILED_FACTS_DIR'] = "./log/"
    end

    before(:each) do
      expect(Inventory::Server::Config).to receive(:etc).and_return({:smtp_port => 2424})
    end

    it "should use the etc configuration" do
      config = Inventory::Server::Config.generate({})
      expect(config[:smtp_port]).to eq 2424
    end

    context "with ENV configuration" do
      before do
        ENV['INVENTORY_HOST'] = "127.0.0.1"
        ENV['INVENTORY_SMTP_PORT'] = "2626"
        ENV['INVENTORY_DEBUG'] = "false"
        ENV['INVENTORY_LOGGER'] = "stdout"
        ENV['INVENTORY_LOG_LEVEL'] = "DEBUG"
        ENV['INVENTORY_PLUGINS'] = "plugin1, plugin2"
        ENV['INVENTORY_PLUGINS_PATH'] = "/path/to/plugin/dir1,/path/to/plugin/dir2"
      end

      after do
        ENV['INVENTORY_HOST'] = nil
        ENV['INVENTORY_SMTP_PORT'] = nil
        ENV['INVENTORY_DEBUG'] = nil
        ENV['INVENTORY_LOGGER'] = nil
        ENV['INVENTORY_LOG_LEVEL'] = nil
        ENV['INVENTORY_PLUGINS'] = nil
        ENV['INVENTORY_PLUGINS_PATH'] = nil
      end

      it "should use the ENV configuration" do
        config = Inventory::Server::Config.generate({})
        expect(config[:host]).to eq '127.0.0.1'
      end

      it "should should cast integer" do
        config = Inventory::Server::Config.generate({})
        expect(config[:smtp_port]).to eq 2626
      end

      it "should should cast boolean" do
        config = Inventory::Server::Config.generate({})
        expect(config[:debug]).to eq false
      end

      it "should should cast stdout/stderr" do
        config = Inventory::Server::Config.generate({})
        expect(config[:logger]).to eq $stdout
      end

      it "should should cast DEBUG/INFO/WARN/ERROR/FATAL" do
        config = Inventory::Server::Config.generate({})
        expect(config[:log_level]).to eq Logger::DEBUG
      end

      it "should should return an array for plugins" do
        config = Inventory::Server::Config.generate({})
        expect(config[:plugins]).to eq ['plugin1', 'plugin2']
      end

      it "should should return an array for plugins_path" do
        config = Inventory::Server::Config.generate({})
        expect(config[:plugins_path]).to eq ['/path/to/plugin/dir1', '/path/to/plugin/dir2']
      end

      context "with CLI configuration" do
        it "should use the CLI configuration" do
          config = Inventory::Server::Config.generate({:smtp_port => 25})
          expect(config[:smtp_port]).to eq 25
        end
      end
    end
  end
end
