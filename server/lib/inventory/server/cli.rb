require 'optparse'
require "inventory/server/version"

module Inventory
  module Server

    class CLI
      
      attr_reader :options

      def initialize()
        @options = {}
      end

      def parse!(args)
        OptionParser.new do|opts|
          opts.banner = "Usage: server [options]"
          opts.separator ""
          opts.separator "Specific options:"

          opts.on("--host HOST", String, "IP or hostname to listen on") do |h|
            @options[:host] = h
          end

          opts.on("--smtp_port PORT", Integer, "SMTP port to listen on") do |p|
            @options[:smtp_port] = p
          end

          opts.on("-es", "--es_host URL", String, "ElasticSerach HTTP URL") do |url|
            @options[:es_host] = url
          end

          opts.on("-o", "--output OUTPUT", String, "Log destination stdout/stderr/file") do |o|
            @options[:logger] = o
          end

          opts.on("-l", "--level LEVEL", ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'], "log level that will be printed DEBUG/INFO/WARN/ERROR/FATAL") do |l|
            @options[:log_level] = l
          end

          opts.on("-d", "--[no-]debug", "how more details, need log_level on DEBUG") do |d|
            @options[:debug] = d
          end

          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end

          opts.on_tail("--version", "Show version") do
            puts VERSION
            exit
          end
        end.parse! args
        @options
      end
    end
  end
end
