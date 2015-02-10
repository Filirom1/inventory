require "rubygems"
require "midi-smtp-server"
require "mail"
require 'rest-client'
require 'json'
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
INDEX="1.0"

class ElasticSearchSmtpRiver < MidiSmtpServer
  def on_message_data_event(ctx)
    begin 
      Filum.logger.context_id = ctx[:envelope][:from]

      # read mail sender
      mail = Mail.read_from_string(ctx[:message])

      Filum.logger.context_id = "#{ctx[:envelope][:from]}-#{mail.message_id}"

      # parse mail body
      facts = JSON.parse(mail.body.decoded)
      id = facts['id'] || facts['hostname']
      version = facts['version'] || '1.0.0'

      Filum.logger.context_id = "#{ctx[:envelope][:from]}-#{mail.message_id}-#{id}"

      # index it into elasticsearch
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
