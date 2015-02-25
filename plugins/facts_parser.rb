# encoding: utf-8
require 'json'
require 'nokogiri'
require 'yaml'
require "base64"
require 'active_support/core_ext/hash'  #from_xml

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

          valid_xml_str = nil
          begin
            valid_xml_str = Nokogiri::XML(str) { |config| config.strict }.to_s
          rescue => e
            raise $!, "Invalid XML #{$!}", $!.backtrace
          end
          hash = Hash.from_xml(valid_xml_str)
          xml = decode_base64(hash)
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

      # decode base64 if present in this deep structure
      def decode_base64(something)
        if something.is_a?(Hash)
          something.each {|key, value|
            something[key] = decode_base64(value)
          }
        elsif something.is_a?(Array)
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
