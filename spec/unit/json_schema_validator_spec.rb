require_relative '../../plugins/json_schema_validator'

require 'rspec/mocks'

noop = lambda {|env| 42}

config = Inventory::Server::Config::defaults

RSpec.describe Inventory::Server::JsonSchemaValidator, '#call' do

  before(:each) do
    JSON::Validator.clear_cache
  end

  context "without facts" do
    it "should throw an error" do
      expect {
        Inventory::Server::JsonSchemaValidator.new(noop, config).call({})
      }.to raise_error 'facts is missing'
    end
  end

  context "without version and type" do
    env = { :facts => { 'key' => 'value'} }
    it "should use the default config" do
      expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/facts.json").and_return false
      expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/facts/1-0-0.json").and_return false
      Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
    end
  end

  context "with type and version integer" do
    env = { :facts => { 'key' => 'value', 'type' => 1, 'version' => 1.0} }
    it "should pass" do
      result = Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
      expect(result).to eq 42
    end
  end

  context "with facts" do
    env = { :facts => { 'key' => 'value', 'type' => 'my_fact', 'version' => 'my_version' } }

    context "without JSON schema" do
      it "should pass" do
        result = Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
        expect(result).to eq 42
      end
    end

    context "with JSON schema" do
      it "should fail if the file is not redable" do
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect {
          Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
        }.to raise_error Errno::ENOENT
      end

      it "should fail if the file is not a valid JSON" do
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact.json").and_return '{"dsf": dsf}'
        expect {
          Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
        }.to raise_error MultiJson::ParseError
      end

      it "should fail if the facts do not respect the type json schema" do
        schema = {
          "type" => "object",
          "properties" => {
            "key"=> {"type" => "integer" }
          }
        }
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact.json").and_return schema.to_json
        expect {
          Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
        }.to raise_error JSON::Schema::ValidationError
      end

      it "should fail if the facts do not respect the version json schema" do
        type_schema = {
          "type" => "object",
          "properties" => {
          }
        }
        version_schema = {
          "type" => "object",
          "properties" => {
            "key"=> {"type" => "integer" }
          }
        }
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return true

        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact.json").and_return type_schema.to_json
        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return version_schema.to_json
        expect {
          Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
        }.to raise_error JSON::Schema::ValidationError
      end

      it "should pass if the facts validate the JSON Schema" do
        schema = {
          "type" => "object",
          "properties" => {
            "key"=> {"type" => "string" }
          }
        }
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return true

        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact.json").and_return schema.to_json
        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return schema.to_json

        Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
      end

      it "should pass if the facts contains more attributes than the JSON Schema " do
        schema = {
          "type" => "object",
          "properties" => {
          }
        }
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return true

        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact.json").and_return schema.to_json
        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return schema.to_json

        Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
      end

      it "should pass if optional fields are not present " do
        schema = {
          "type" => "object",
          "properties" => {
            "optional"=> {"type" => "string" }
          }
        }
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return true

        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact.json").and_return schema.to_json
        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact/my_version.json").and_return schema.to_json

        Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
      end

      it "should fail if mandatory fields are not present " do
        schema = {
          "type" => "object",
          "required" => ["mandatory"],
          "properties" => {
            "mandatory"=> {"type" => "string" }
          }
        }
        expect(File).to receive(:file?).with("#{config[:json_schema_dir]}/my_fact.json").and_return true
        expect(File).to receive(:read).with("#{config[:json_schema_dir]}/my_fact.json").and_return schema.to_json

        expect {
          Inventory::Server::JsonSchemaValidator.new(noop, config).call(env)
        }.to raise_error JSON::Schema::ValidationError
      end
    end
  end

end
