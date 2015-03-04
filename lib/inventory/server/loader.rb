require 'inventory/server/inventory_error'
require 'inventory/server/logger'

PLUGINS_DIR = Pathname.new(File.join File.dirname(__FILE__), '..', '..', '..', 'plugins').cleanpath

module Inventory
  module Server
    class Loader
      def initialize(config)
        @plugins_path = [PLUGINS_DIR]
        @plugins_path << config[:plugins_path] if config[:plugins_path]
        @plugins_path.each { |path|
          raise InventoryError.new "plugins_path #{path} not found" unless File.directory? path
        }
        @loaded = []
      end

      # search for plugins in the plugins_path and return a hash of plugin_filename:plugin_klass
      def load_plugins(*plugins)
        plugin_klasses = []
        plugins.each {|plugin|
          p = nil
          @plugins_path.each {|plugin_path|
            filepath = File.join plugin_path, "#{plugin}.rb"
            next unless File.file? filepath
            load_file filepath
            klass_name = classify(plugin)
            p = Object.const_get("Inventory").const_get("Server").const_get(klass_name)
          }
          raise InventoryError.new "Plugin #{plugin} not found" if !p
          plugin_klasses << p
        }
        return plugin_klasses
      end

      # Load a ruby file if not already loaded
      def load_file(file)
        return if @loaded.include? file

        begin
          @loaded << file
          kernel_load(file)
        rescue => e
          @loaded.delete(file)
          InventoryLogger.logger.error("Fail to load #{file}: #{e}")
        end
      end

      # Usefull for tests
      def kernel_load(file)
        InventoryLogger.logger.info "Load #{file}"
        require file
      end

      # transform a snake case string into a upper camel case string
      def classify(str)
        str.split('_').collect!{ |w| w.capitalize }.join
      end
    end
  end
end
