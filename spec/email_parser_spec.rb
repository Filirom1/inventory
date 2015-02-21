require 'inventory/server/email_parser'

require 'mail'
require "filum"

Filum.setup '/dev/null'

RSpec.describe Inventory::Server::EmailParser, '#call' do

  context "without email subject" do
    mail = Mail.new do
      from    'filirom1@toto.com'
      to      'filirom2@toto.com'
      subject ''
      body    '{"key": "value"}'
    end

    it "should throw an error" do
      expect {
        Inventory::Server::EmailParser.parse(mail.to_s)
      }.to raise_error 'email subject is missing'
    end
  end

  context "without email body" do
    mail = Mail.new do
      from    'filirom1@toto.com'
      to      'filirom2@toto.com'
      subject 'MY_UUID'
      body    ''
    end

    it "should throw an error" do
      expect {
        Inventory::Server::EmailParser.parse(mail.to_s)
      }.to raise_error 'email body is missing'
    end
  end

  context "with a valid email" do
    mail = Mail.new do
      from    'filirom1@toto.com'
      to      'filirom2@toto.com'
      subject 'MY_UUID'
      body    '{"key": "value"}'
    end

    it "should parse the email" do
      id, body = Inventory::Server::EmailParser.parse(mail.to_s)

      expect(id).to eq 'MY_UUID'
      expect(body).to eq '{"key": "value"}'
    end
  end
end

