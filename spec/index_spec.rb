require 'inventory/server/index'

require "filum"
require 'webmock/rspec'

Filum.setup '/dev/null'

noop = lambda {|env|}

ES_HOST = 'http://localhost:9200'
config = { :es_host => ES_HOST }  

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
      stub_request(:put, "#{ES_HOST}/server/1.0.0/MY_UUID").to_return(:status => [500, "Internal Server Error"], :body => '{"OK": false}')

      expect {
        Inventory::Server::Index.new(noop, config).call(env)
      }.to raise_error(/500 Internal Server Error: {"OK": false}/)
    end
  end

  context "with an ElasticSearch Server" do
    env = {:id => 'MY_UUID', :facts => { :key => 'value' } }

    it "should call ElasticSearch" do
      stub = stub_request(:put, "#{ES_HOST}/server/1.0.0/MY_UUID").to_return(:body => '{"OK": true}')

      Inventory::Server::Index.new(noop, config).call(env)

      expect(stub).to have_been_requested
    end
  end
end
