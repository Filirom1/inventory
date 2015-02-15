require 'json'
require 'crack'
require 'yaml'

module Inventory
  module Server
    class FactsParser
      def initialize(app)
        @app = app
      end

      def call(env)
        Filum.logger.info "Facts parser"
        body = env[:body]
        raise "body missing" if body.nil? || body.empty?

        format = guess_format body
        raise "bad format" if !format

        env[:facts] = parse(format, body)
        @app.call(env)
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
      def parse(format, str)
        case format
        when :xml
          hash = Crack::XML.parse(str)
          xml = decode_base64(nil, hash)
          keys = xml.keys
          if keys.length == 1
            return xml[keys[0]] 
          else
            return xml
          end
        when :json
          JSON.parse str
        when :yaml
          YAML.load str
        end
      end

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
    end
  end
end
