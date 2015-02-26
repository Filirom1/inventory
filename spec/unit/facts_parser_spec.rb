# encoding: utf-8
require_relative '../../plugins/facts_parser'

noop = lambda {|env|}

RSpec.describe Inventory::Server::FactsParser, '#call' do
  context "without body" do
    env = { :body => nil }
    it "should throw an error" do
      expect {
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error 'body missing'
    end
  end

  context "with bad format" do
    env = { :body => 'blablayuqsd' }
    it "should throw an error" do
      expect {
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error 'bad format'
    end
  end

  context "with bad JSON" do
    env = { :body => '{toto:12}' }
    it "should throw an error" do
      expect {
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error JSON::ParserError
    end
  end

  context "with good JSON" do
    env = { :body => '{"key":"value"}' }
    it "should throw an error" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq 'key' => 'value'
    end
  end

  context "with bad YAML" do
    env = { :body => '''---
            play:
            toto''' }
    it "should throw an error" do
      expect {
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error Psych::SyntaxError
    end
  end

  context "with good YAML" do
    env = { :body => '''---
            key: value''' }
    it "should throw an error" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq 'key' => 'value'
    end
  end

  context "with bad XML" do
    env = { :body => '''<Inventory>blabla</Intory>''' }
    it "should throw an error" do
      expect {
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error /Invalid XML/
    end
  end

  context "with an other bad XML" do
    env = { :body => '''
            <inventory>
              <key>value</key>
              text
            </inventory>''' }
    it "should throw an error" do
      expect {
        Inventory::Server::FactsParser.new(noop, {}).call(env)
      }.to raise_error /Invalid XML/
    end
  end

  context "with good XML" do
    env = { :body => '''
            <inventory>
              <key>value</key>
            </inventory>''' }
    it "should parse it" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq 'key' => 'value'
    end
  end

  context "with XML using empty node" do
    env = { :body => '''
            <inventory>
              <key></key>
            </inventory>''' }
    it "should return nil" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq 'key' => nil
    end
  end


  context "with good XML with base64 in object" do
    env = { :body => '''
            <inventory>
              <key>value</key>
              <obj>
                <key>__base64__dmFsdWU=</key>
              </obj>
            </inventory>''' }
    it "should parse it" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq({ 'key' =>'value', 'obj' => { 'key' => 'value' } })
    end
  end

  context "with good XML with base64 in array" do
    env = { :body => '''
            <inventory>
              <key>value</key>
              <array>
                <value>__base64__dmFsdWU=</value>
                <value>__base64__dmFsdWU=</value>
              </array>
            </inventory>''' }
    it "should parse it" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq({ 'key' =>'value', 'array' => { 'value' => ['value', 'value']}})
    end
  end

  context "with XML base64 containing UTF-8 encodings" do
    env = { :body => '''
            <inventory>
              <key>value</key>
              <obj>
                <key>__base64__aMOpaMOp</key>
              </obj>
            </inventory>''' }
    it "should parse it" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq({ 'key' =>'value', 'obj' => { 'key' => "h\xc3\xa9h\xc3\xa9" } })
    end
  end

  context "with XML base64 containing ISO-8859-1 encodings" do
    env = { :body => '''
            <inventory>
              <key>value</key>
              <obj>
                <key>__base64__aOlo6Q==</key>
              </obj>
            </inventory>''' }
    it "should parse it" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
      expect(env[:facts]).to eq({ 'key' =>'value', 'obj' => { 'key' => "h\xc3\xa9h\xc3\xa9" } })
    end
  end

  context "with XML base64 containing Japonese encodings" do
    env = { :body => '''
            <inventory>
              <key>value</key>
              <obj>
                <key>__base64__grGC8YLJgr+CzQ==</key>
              </obj>
            </inventory>''' }
    it "should not throw an error" do
      Inventory::Server::FactsParser.new(noop, {}).call(env)
    end
  end
end
