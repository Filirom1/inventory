require 'filum'
require 'app_configuration'

module Inventory
  module Server

    class Config

      def initialize(cli_config)
        @defaults = {
          :host => '127.0.0.1',
          :smtp_port => 2525,
          :http_port => 8080,
          :max_connections => 4,
          :debug => false,
          :es_host => 'http://localhost:9200',
          :logger => 'stdout',
          :log_level => 'INFO'
        }

        @config = AppConfiguration.new('inventory.yml') do
          base_global_path '/etc'
          use_env_variables true
          prefix 'inventory' # ENV prefix: INVENTORY_XXXXX
        end

        @cli_config = cli_config;
      end

      def [](sym)
        val =  @cli_config[sym] || @config[sym.to_s] || @defaults[sym]

        # cast config values (ENV values are strings only)
        if @defaults[sym].is_a? Integer
          return val.to_i
        elsif !!@defaults[sym] == @defaults[sym]
          # Boolean
          if val == true || val =~ /^(true|t|yes|y|1)$/i
            return true
          elsif val == false || val.blank? || val =~ /^(false|f|no|n|0)$/i
            return false
          end
        # Logging
        elsif val == 'stdout'
          return $stdout
        elsif val == 'stderr'
          return $stderr
        # Logging Level
        elsif val == 'INFO'
          return Logger::INFO
        elsif val == 'DEBUG'
          return Logger::DEBUG
        elsif val == 'WARN'
          return Logger::WARN
        elsif val == 'ERROR'
          return Logger::ERROR
        elsif val == 'FATAL'
          return Logger::FATAL
        end
        return val
      end
    end
  end
end

