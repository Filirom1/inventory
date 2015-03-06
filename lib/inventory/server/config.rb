require 'yaml'
require 'fileutils'
require "inventory/server/logger"

module Inventory
  module Server

    module Config
      def self.generate(cli_config)
        mapping = {
          'stdout'=> $stdout,
          'stderr'=> $stderr,
          'INFO'=>Logger::INFO,
          'DEBUG'=>Logger::DEBUG,
          'WARN'=>Logger::WARN,
          'ERROR'=>Logger::ERROR,
          'FATAL'=>Logger::FATAL
        }

        config = self.defaults.merge self.etc.merge self.env.merge cli_config

        config.each{|sym, val|
          next unless val
          config[sym] = mapping[val] if mapping[val]

          if val.is_a? String and [:plugins, :plugins_path].include? sym
            config[sym] = val.split(',').collect(&:strip)
          end
        }

        FileUtils.mkdir_p config[:failed_facts_dir]

        return config
      end

      private

      def self.load_yaml(filepath)
        begin
          hash = YAML.load_file filepath
        rescue
          return {}
        end
        self.sym_keys! hash
        hash
      end

      def self.defaults()
        default_filename = File.join File.dirname(__FILE__), '..', '..', '..', 'config', 'inventory.yml'
        self.load_yaml default_filename
      end

      def self.etc()
        self.load_yaml "/etc/inventory/inventory.yml"
      end

      def self.sym_keys!(hash)
        hash.keys.each do |key|
            hash[(key.to_sym rescue key) || key] = hash.delete(key)
        end
      end

      def self.env()
        hash = {}
        ENV.each {|key, value|
          next unless key.start_with? 'INVENTORY_'
          key = key.gsub 'INVENTORY_', ''
          key = key.downcase
          hash[key] = value
        }

        # This is an ugly trick to auto cast data types
        hash = YAML.load(hash.map{|k,v| "#{k}: #{v}"}.join("\n")) || {}

        self.sym_keys! hash
        hash
      end
    end
  end
end

