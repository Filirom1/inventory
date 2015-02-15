require 'inventory/server/email_parser'

require 'mail'
require "filum"

Filum.setup '/dev/null'

noop = lambda {|env|}

RSpec.describe Inventory::Server::EmailParser, '#call' do
  context "without email" do
    env = { :ctx => nil }
    it "should throw an error" do
      expect {
        Inventory::Server::EmailParser.new(noop).call(env)
      }.to raise_error 'ctx missing'
    end
  end

  context "without email message" do
    env = { :ctx => { :message => nil } }
    it "should throw an error" do
      expect {
        Inventory::Server::EmailParser.new(noop).call(env)
      }.to raise_error 'ctx message missing'
    end
  end

  context "without email subject" do
    mail = Mail.new do
      from    'filirom1@toto.com'
      to      'filirom2@toto.com'
      subject ''
      body    '{"key": "value"}'
    end
    env = { :ctx => { :message => mail.to_s } }

    it "should throw an error" do
      expect {
        Inventory::Server::EmailParser.new(noop).call(env)
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
    env = { :ctx => { :message => mail.to_s } }

    it "should throw an error" do
      expect {
        Inventory::Server::EmailParser.new(noop).call(env)
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
    env = { :ctx => { :message => mail.to_s } }

    it "should parse the email" do
      Inventory::Server::EmailParser.new(noop).call(env)

      expect(env[:id]).to eq 'MY_UUID'
      expect(env[:body]).to eq '{"key": "value"}'
    end
  end
end

