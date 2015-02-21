module Inventory
  module Server
    class LogFailuresOnDisk
      def initialize(app, config)
        @app = app
        @failed_facts_dir = config[:failed_facts_dir]
      end

      def call(env)
        id = env[:id]
        raise 'id missing' if id.nil? || id.empty?

        body = env[:body]
        raise "body missing" if body.nil? || body.empty?

        begin
          @app.call(env)
        rescue => e
          filepath = "#{@failed_facts_dir}/#{id}"
          Filum.logger.error $!
          Filum.logger.error "Failed facts stored on #{filepath}"
          Filum.logger.error "#{e.backtrace}"

          File.write(filepath, body)
        end
      end
    end
  end
end

# http://www.mattburkedev.com/shim-file-dot-write-in-ruby-1-dot-8-7/
unless File.respond_to?(:write)
  class File
    def self.write(filename, contents)
      File.open(filename, 'w') do |file|
        file.write contents
      end
    end
  end
end
