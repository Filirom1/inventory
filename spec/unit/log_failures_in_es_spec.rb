require_relative '../../plugins/log_failures_in_es'
require 'rspec/mocks'

noop = lambda {|env| 42}

RSpec.describe Inventory::Server::LogFailuresInEs do
  config = { :failed_facts_dir => './log' , :es_failure_index => "itdiscovery-failures", :es_failure_type => "v1", :es_host => "http://localhost:9200"}

  context "without body" do
    env = { :id => 'id', :body => nil }
    it "should throw an error" do
      expect {
        Inventory::Server::LogFailuresInEs.new(noop, config).call(env)
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error 'body missing'
    end
  end

  context "without id" do
    env = { :id => nil, :body => 'body' }
    it "should throw an error" do
      expect {
        Inventory::Server::LogFailuresInEs.new(noop, config).call(env)
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error 'id missing'
    end
  end

  context "with all mandatory params" do
    env = { :id => 'MY_UUID', :body => 'my_body' }

    context "without error" do
      it "should pass without writing anything" do
        expect(RestClient).to receive(:delete).with('http://localhost:9200/itdiscovery-failures/v1/MY_UUID')
        expect(RestClient).to_not receive(:put).with(any_args)
        result = Inventory::Server::LogFailuresInEs.new(noop, config).call(env)
        expect(result).to eq 42
      end
    end

    context "with error" do
      it "should write facts" do
        raise_error = lambda{ |e| raise "an error" }
        expect(RestClient).to receive(:put).with('http://localhost:9200/itdiscovery-failures/v1/MY_UUID', /(?=.*my_body)(?=.*an error)(?=.*log_failures_in_es_spec.rb:)/)
        expect {
          Inventory::Server::LogFailuresInEs.new(raise_error, config).call(env)
        }.to raise_error 'an error'
      end
    end
  end
end
