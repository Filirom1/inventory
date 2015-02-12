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
        data = env[:body]
        raise "data missing" if !data

        format = guess_format data
        raise "bad format" if !format

        env[:facts] = parse(format, data)

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
          decode_base64(nil, hash)
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
