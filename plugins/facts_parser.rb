# encoding: utf-8
require 'json'
require 'yaml'
require "base64"
require 'libxml_to_hash'

require 'ensure/encoding'
require 'inventory/server/inventory_error'
require "inventory/server/logger"

module Inventory
  module Server
    class FactsParser
      def initialize(app, config)
        @app = app
        @config = config
      end

      def call(env)
        InventoryLogger.logger.info "Facts parser"
        body = env[:body]
        raise InventoryError.new "body missing" if body.nil? || body.empty?

        format = guess_format body
        raise InventoryError.new "bad format" if !format

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
          # XML validation

          hash = nil
          begin
            hash = Hash.from_libxml! str
            xml = decode_base64(hash)
            keys = xml.keys
            if keys.length == 1
              xml = xml[keys[0]]
            end
            raise "Expect < found #{xml.text} " if xml.is_a?(LibXmlNode) and  xml.text != ""
            return xml
          rescue => e
            raise $!, "Invalid XML #{$!}", $!.backtrace
          end
        when :json
          JSON.parse str
        when :yaml
          YAML.load str
        end
      end

      # decode base64 if present in this deep structure
      def decode_base64(something)
        if something.is_a?(Hash)
          return nil if something.empty?
          something.each {|key, value|
            something[key] = decode_base64(value)
          }
        elsif something.is_a?(Array)
          return nil if something.empty?
          something = something.map {|value|
            decode_base64(value)
          }
        elsif something.is_a?(String) and something.include? "__base64__"
          something.slice!("__base64__")
          fix_bad_encoding Base64.decode64(something);
        else
          something
        end
      end

      def fix_bad_encoding(str)
        str.ensure_encoding('UTF-8',
          :external_encoding  => [Encoding::UTF_8, Encoding::ISO_8859_1],
          :invalid_characters => :transcode
        )
      end
    end
  end
end
