require "mail"
require 'inventory/server/inventory_error'
require "inventory/server/logger"

module Inventory
  module Server
    class EmailParser
      def self.parse(message)
        InventoryLogger.logger.info "Email parser"

        # Parse the email
        email = Mail.read_from_string(message)

        # Use email subject as an ID
        email_subject = email.subject
        raise InventoryError.new "email subject is missing" if email_subject.nil? || email_subject.empty?
        id = email_subject

        # Decode the email body
        email_body = email.body.decoded
        raise InventoryError.new "email body is missing" if email_body.nil? || email_body.empty?
        body = email_body

        return id, body
      end
    end
  end
end
