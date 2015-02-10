require "rubygems"
require "midi-smtp-server"
require "mail"
require 'rest-client'
require 'json'
require 'crack'
require 'yaml'
require 'filum'

Filum.setup($stdout)
Filum.logger.level = Logger::DEBUG

# Forward RestClient logs to Filum
RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      Filum.logger.debug message
    end
  end

BASE_URL="http://localhost:9200/"
TYPE="inventory"

# decode base64 if present in hash values
def decode_base64(parent, myHash)
  myHash.each {|key, value|
    if value.is_a?(Hash)
      decode_base64(key, value)
    elsif value.is_a? String and value.include? "__base64__"
      value.slice!("__base64__")
      myHash[key] = Base64.decode64(value)
    end
  }
end

# guess about the format of `str`
def guess_format(str)
  case str
  when /\A\s*[\[\{]/ then :json
  when /\A\s*</ then :xml
  when /\A---\s/ then :yaml
  end
end

# Parse str into a hash, the format will ne guessed
def parse(str)
  case guess_format str
  when :xml
    hash = Crack::XML.parse(str)
    decode_base64(nil, hash)
  when :json
    JSON.parse str
  when :yaml
    YAML.load str
  end
end

# Create an SMTP Server
class ElasticSearchSmtpRiver < MidiSmtpServer
  def on_message_data_event(ctx)
    begin 
      Filum.logger.context_id = ctx[:envelope][:from]

      # Parse email
      mail = Mail.read_from_string(ctx[:message])

      Filum.logger.context_id = "#{ctx[:envelope][:from]}-#{mail.message_id}"

      # Parse body
      facts = parse(mail.body.decoded)

      # Set default values
      id = facts['id'] || facts['hostname']
      version = facts['version'] || '1.0.0'

      Filum.logger.context_id = "#{ctx[:envelope][:from]}-#{mail.message_id}-#{id}"

      # Index it into elasticsearch
      response =  RestClient.put("#{BASE_URL}/#{version}/#{TYPE}/#{id}", facts.to_json)
      Filum.logger.info response
    rescue => e
      Filum.logger.warn e
    end
  end
end

server = ElasticSearchSmtpRiver.new(2525, "127.0.0.1", 50)
server.audit = ENV['debug']
server.start
server.join
