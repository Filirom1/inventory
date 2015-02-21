require 'filum'
require 'app_configuration'
require 'fileutils'

module Inventory
  module Server

    module Config
      DEFAULTS = {
        :host => '127.0.0.1',
        :smtp_port => 2525,
        :http_port => 8080,
        :max_connections => 4,
        :debug => false,
        :es_host => 'http://localhost:9200',
        :failed_facts_dir => '/var/log/inventory/failures/',
        :logger => 'stdout',
        :log_level => 'INFO'
      }

      def self.generate(cli_config)

        global = AppConfiguration.new('inventory.yml') do
          base_global_path '/etc'
          use_env_variables true
          prefix 'inventory' # ENV prefix: INVENTORY_XXXXX
        end

        config = {}

        DEFAULTS.each{|sym, default_value|

          val =  cli_config[sym] || global[sym.to_s] || default_value
          result = val

          # cast config values (ENV values are strings only)
          if default_value.is_a? Integer
            result = val.to_i
          elsif !!default_value == default_value
            # Boolean
            if val == true || val =~ /^(true|t|yes|y|1)$/i
              result = true
            elsif val == false || val.blank? || val =~ /^(false|f|no|n|0)$/i
              result = false
            end
          # Logging
          elsif val == 'stdout'
            result = $stdout
          elsif val == 'stderr'
            result = $stderr
          # Logging Level
          elsif val == 'INFO'
            result = Logger::INFO
          elsif val == 'DEBUG'
            result = Logger::DEBUG
          elsif val == 'WARN'
            result = Logger::WARN
          elsif val == 'ERROR'
            result = Logger::ERROR
          elsif val == 'FATAL'
            result = Logger::FATAL
          end
          config[sym] = result
        }

        FileUtils.mkdir_p config[:failed_facts_dir]

        config
      end
    end
  end
end

