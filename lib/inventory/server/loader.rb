require 'filum'

module Inventory
  module Server
    class Loader
      def initialize(config)
        @plugins_path = [File.dirname(__FILE__)] + config[:plugins_path].split(',')
        @plugins_path.each { |path|
          raise "plugins_path #{path} not found" unless File.directory? path
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
          raise "Plugin #{plugin} not found" if !p
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
          Filum.logger.error("Fail to load #{file}: #{e}")
        end
      end

      # Usefull for tests
      def kernel_load(file)
        Filum.logger.info "Load #{file}"
        require file
      end

      # transform a snake case string into a upper camel case string
      def classify(str)
        str.split('_').collect!{ |w| w.capitalize }.join
      end
    end
  end
end