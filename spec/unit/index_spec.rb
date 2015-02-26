# encoding: utf-8
require_relative '../../plugins/index'

require 'webmock/rspec'

noop = lambda {|env|}

config = Inventory::Server::Config::DEFAULTS

RSpec.describe Inventory::Server::Index, '#call' do
  # needed for code climates to work after rspec
  before(:all) do
    WebMock.disable_net_connect!
  end
  after(:all) do
    WebMock.allow_net_connect!
  end

  context "without id" do
    env = {:facts => { :key => 'value' }}
    it "should throw an error" do
      expect {
        Inventory::Server::Index.new(noop, config).call(env)
      }.to raise_error 'id is missing'
    end
  end

  context "without facts" do
    env = {:id => 'MY_UUID' }
    it "should throw an error" do
      expect {
        Inventory::Server::Index.new(noop, config).call(env)
      }.to raise_error 'facts is missing'
    end
  end

  context "with an ElasticSearch Server Crashed" do
    env = {:id => 'MY_UUID', :facts => { :key => 'value' } }

    it "should throw an error" do
      stub_request(:put, "#{config[:es_host]}/inventory_facts/1-0-0/MY_UUID").to_return(:status => [500, "Internal Server Error"], :body => '{"OK": false}')

      expect {
        Inventory::Server::Index.new(noop, config).call(env)
      }.to raise_error(/500 Internal Server Error: {"OK": false}/)
    end
  end

  context "with an ElasticSearch Server" do
    it "should call ElasticSearch" do
      env = {:id => 'MY_UUID', :facts => { :key => 'value' } }
      stub = stub_request(:put, "#{config[:es_host]}/inventory_facts/1-0-0/MY_UUID").to_return(:body => '{"OK": true}')

      Inventory::Server::Index.new(noop, config).call(env)

      expect(stub).to have_been_requested
    end

    it "should change url depending on the type and version" do
      env = {:id => 'MY_UUID', :facts => { 'key' => 'value', 'type' => 'my_type', 'version' => 'my_version' } }
      stub = stub_request(:put, "#{config[:es_host]}/inventory_my_type/my_version/MY_UUID").to_return(:body => '{"OK": true}')

      Inventory::Server::Index.new(noop, config).call(env)

      expect(stub).to have_been_requested
    end

    it "should change not pass dot, spaces and utf8 to elasticsearch" do
      env = {:id => 'MY_UUID', :facts => { 'key' => 'value', 'type' => 'my typé.1', 'version' => 'my vérsion.1' } }
      stub = stub_request(:put, "#{config[:es_host]}/inventory_my_typ-1/my_vrsion-1/MY_UUID").to_return(:body => '{"OK": true}')

      Inventory::Server::Index.new(noop, config).call(env)

      expect(stub).to have_been_requested
    end
  end
end
