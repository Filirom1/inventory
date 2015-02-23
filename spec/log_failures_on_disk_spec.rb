require_relative '../plugins/log_failures_on_disk'
require 'rspec/mocks'

noop = lambda {|env|}

RSpec.describe Inventory::Server::LogFailuresOnDisk do
  config = { :failed_facts_dir => './log' }

  context "without body" do
    env = { :id => 'id', :body => nil }
    it "should throw an error" do
      expect {
        Inventory::Server::LogFailuresOnDisk.new(noop, config).call(env)
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error 'body missing'
    end
  end

  context "without id" do
    env = { :id => nil, :body => 'body' }
    it "should throw an error" do
      expect {
        Inventory::Server::LogFailuresOnDisk.new(noop, config).call(env)
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error 'id missing'
    end
  end

  context "with all mandatory params" do
    env = { :id => 'MY_UUID', :body => 'body' }

    context "without error" do
      it "should pass without writing anything" do
        Inventory::Server::LogFailuresOnDisk.new(noop, config).call(env)
        expect(File).to_not receive(:write)
      end
    end

    context "with error" do
      it "should write facts" do
        raise_error = lambda{ |e| raise "an error" }
        expect(File).to receive(:write).with('./log/MY_UUID', 'body')
        Inventory::Server::LogFailuresOnDisk.new(raise_error, config).call(env)
      end
    end
  end
end
