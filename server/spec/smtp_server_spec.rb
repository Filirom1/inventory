require 'inventory/server/smtp_server'

require 'mail'
require "filum"
require "middleware"

Filum.setup '/dev/null'

PORT=2526
HOST="127.0.0.1"

Mail.defaults do
    delivery_method :smtp, address: HOST, port: PORT
end

RSpec.describe Inventory::Server::SMTPServer do
  context "With an SMTPServer running" do

    smtp_server = nil
    executed = nil
    trigger_error = nil
    mail = nil

    before(:all) do

      # Start SMTPServer
      config = {
        :host => HOST, 
        :port => PORT,
        :maxConnections => 1,
        :middleware => lambda { |env|  
          executed += 1
          raise 'my custom error message' if trigger_error
        }
      }

      smtp_server = Inventory::Server::SMTPServer.new(config)
      smtp_server.audit = true
      smtp_server.start
    end

    before(:each) do
      # Reset context variables
      executed = 0
      trigger_error = false

      mail = Mail.new do
        from     'rspec@localhost'
        to       'midi@localhost'
        subject  'MY_UUID'
        body     '{"key": "value"}'
      end
    end

    it "should accept mails" do
      mail.deliver!

      expect(executed).to eq 1
    end

    it "should not raise error when processing fails" do
      trigger_error = true
      mail.deliver!
      expect(executed).to eq 1
    end

    after(:all) do
      smtp_server.stop
    end
  end
end
